package org.wirp;

import lombok.extern.slf4j.Slf4j;
import party.iroiro.luajava.Lua;
import party.iroiro.luajava.lua54.Lua54;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Objects;
import java.util.Properties;

@Slf4j
public class LuaFileRun {

    public static void main(String[] args) throws URISyntaxException {

        Properties prop = new Properties();

        ClassLoader classLoader = LuaFileRun.class.getClassLoader();
        try {

            try(FileInputStream inputProps = new FileInputStream("config.properties")) {
                prop.load(inputProps);
            }

            Path mockPath = Path.of(
                    Objects.requireNonNull(
                            classLoader.getResource(
                                    "mods/Mock.lua"))
                            .toURI());
            Path scriptPath = Path.of(
                    Objects.requireNonNull(
                                    classLoader.getResource(
                                                    prop.getProperty("SCRIPT")))
                            .toURI());
            String mock = Files.readString(mockPath);
            String script = Files.readString(scriptPath);

            log.debug("Script text:\n{}", script);
            try (Lua lua54 = new Lua54()) {
                Lua.LuaError errorMock = lua54.run(mock);
                Lua.LuaError errorScript = lua54.run(script);
                if (errorMock != Lua.LuaError.OK || errorScript != Lua.LuaError.OK) {
                    log.error("Error running script: mock status {}, script status {}",
                            errorMock,
                            errorScript);
                } else {
                    log.debug("Script done");
                }
            }
        } catch (URISyntaxException | IOException e) {
            log.error("Error reading script file: ", e);
        }
    }
}