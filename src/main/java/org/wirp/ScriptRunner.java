package org.wirp;

import lombok.extern.slf4j.Slf4j;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaError;
import org.luaj.vm2.lib.jse.JsePlatform;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Path;
import java.util.Objects;
import java.util.Properties;

@Slf4j
public class ScriptRunner {

    public static void main(String[] args) throws URISyntaxException {

        Properties prop = new Properties();

        ClassLoader classLoader = ScriptRunner.class.getClassLoader();
        try(FileInputStream inputProps = new FileInputStream("config.properties")) {
            prop.load(inputProps);

            Globals globals = JsePlatform.standardGlobals();

            loadLuaFile(classLoader, "mods/Mock.lua", globals);
            loadLuaFile(classLoader, prop.getProperty("SCRIPT"), globals);

        } catch (IOException | LuaError e) {
            log.error("Error running script file: ", e);
        }
    }

    private static void loadLuaFile(ClassLoader classLoader, String filePath, Globals globals)
            throws URISyntaxException, LuaError {
        String scriptPath = Path.of(
                Objects.requireNonNull(
                        classLoader.getResource(filePath)).toURI()).toString();

        globals.loadfile(scriptPath).call();
    }
}