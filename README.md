# Assistant in writing and fixing mods | Помощник в написании и исправлении модов для сервера "What If...?" (Project Zomboid)

### (_EN_) Requirements:
* Intellij Idea
* Java 17
* Mod sources
* Installed PZ
* EmmyLua Plugin for Idea https://plugins.jetbrains.com/plugin/9768-emmylua

---

To begin with, we will use the project for generating PZ jar sources https://github.com/Konijima/PZ-Libraries.<br>
Following the instructions, we obtain two jar files that we need: _zdoc-lua.jar_ (.lua) and _zomboid.jar_ (.classes) - containing the required version of lua and java from PZ.<br>
`Note: these files need to be recompiled when PZ is updated!`<br>
These files should be placed in the lib folder of the project and replace any existing ones if necessary.<br>

The sources of the mods themselves should be placed in the _src/main/resources/mods/_ folder.<br>
Next, we need to specify the path to the mod script that we want to modify in the configuration file: _config.properties_ (_src/main/resources/config.properties_).<br>
For example: `SCRIPT=mods/mod_folder/media/lua/server/script_name.lua`

Execute _gradle build_, then _gradle run_ (to launch the code check).

![gradle_cut.png](shortcut/gradle_cut.png)

### Example:
Let's run the lua from the Prisoner mod, specifying the path in _config.properties_:<br>
`SCRIPT=mods/Prisonner/media/lua/server/BP_Moddata_Server.lua`<br><br>

We get the following log:
````
00:15:24.209 [main] ERROR org.wirp.ScriptRunner -- Error running script file: 
org.luaj.vm2.LuaError: @C:\Users\User\IdeaProjects\wirp\build\resources\main\mods\Prisonner\media\lua\server\BP_Moddata_Server.lua:2 attempt to call nil
	at org.luaj.vm2.LuaValue.checkmetatag(Unknown Source)
	at org.luaj.vm2.LuaValue.callmt(Unknown Source)
	at org.luaj.vm2.LuaValue.call(Unknown Source)
	at org.luaj.vm2.LuaClosure.execute(Unknown Source)
	at org.luaj.vm2.LuaClosure.call(Unknown Source)
	at org.wirp.ScriptRunner.loadLuaFile(ScriptRunner.java:42)
	at org.wirp.ScriptRunner.main(ScriptRunner.java:29)
````
The program ran, but we received a message that the script is not working correctly.<br>
This does not mean that the script does not work, let's shorten the contents of the script to:
````
if isClient() then return; end;

playerdataServer = {};
playerdataServer.Verbose = false
--[[--======== Players ========--
]]--
````
The error was due to the code using the function _isClient()_, which determines whether the player is a client.<br>
The project has a file: _src/main/resources/mods/Mock.lua_, which will help us make a mock of this function call.<br>
Let's make the following changes to it and try to run it:

````
function isClient()
    return false
end

local mockEvents = {}

function mockEvents.OnClientCommand_Add(callback)
    print("Mock method called with callback!\n", callback)
end

Events = {
    OnClientCommand = {
        Add = mockEvents.OnClientCommand_Add
    }
}
````

---

### (_РУС_) Требования:
* Intellij Idea
* Java 17
* Исходники модов
* Установленный PZ
* EmmyLua Plugin для Idea https://plugins.jetbrains.com/plugin/9768-emmylua

---

Для начала воспользуемся проектом для генерации jar исходников PZ https://github.com/Konijima/PZ-Libraries.<br>
По инструкции получаем нужные нам два jar файла: _zdoc-lua.jar_ (.lua) и _zomboid.jar_ (.classes) — , содержащие lua и java из нужной нам верссии PZ.<br>
`При обновлении PZ их нужно перекомпилировать!`<br>
Эти файлы требуется переложить в папку lib проекта, если надо — заменить имеющиеся.<br>

Исходники самих модов кладутся в папку _src/main/resources/mods/_<br>
Далее нужно прописать путь к скрипту мода, который мы хотим изменять, в настроечном файле: _config.properties_ (_src/main/resources/config.properties_).<br>
Например: `SCRIPT=mods/*папка_с_модом*/media/lua/server/*название_скрипта*.lua`

Выполнить _gradle build_, потом — _gradle run_ (запуск проверки кода)

![gradle_cut.png](shortcut/gradle_cut.png)

### Пример
Запустим lua из мода Prisoner, указав путь в _config.properties_:<br>
`SCRIPT=mods/Prisonner/media/lua/server/BP_Moddata_Server.lua`<br><br>
Получим лог:
````
00:15:24.209 [main] ERROR org.wirp.ScriptRunner -- Error running script file: 
org.luaj.vm2.LuaError: @C:\Users\User\IdeaProjects\wirp\build\resources\main\mods\Prisonner\media\lua\server\BP_Moddata_Server.lua:2 attempt to call nil
	at org.luaj.vm2.LuaValue.checkmetatag(Unknown Source)
	at org.luaj.vm2.LuaValue.callmt(Unknown Source)
	at org.luaj.vm2.LuaValue.call(Unknown Source)
	at org.luaj.vm2.LuaClosure.execute(Unknown Source)
	at org.luaj.vm2.LuaClosure.call(Unknown Source)
	at org.wirp.ScriptRunner.loadLuaFile(ScriptRunner.java:42)
	at org.wirp.ScriptRunner.main(ScriptRunner.java:29)
````
Программа отработала, но мы получили сообщение, что скрипт неисправен.<br>
Это не означает, что скрипт не работает, давайте сократим содержимое скрипта до:
````
if isClient() then return; end;

playerdataServer = {};
playerdataServer.Verbose = false
--[[--======== Players ========--
]]--
````
Ошибка заключалась в том, что код использует функцию _isClient()_, которая определает является ли игрок клиентом.<br>
В проекте есть файл: _src/main/resources/mods/Mock.lua_, который поможет нам сделать заглушку на данном вызове функции.<br>
Внесем в него следующие правки и попробуем запустить:
````
function isClient()
    return false
end

local mockEvents = {}

function mockEvents.OnClientCommand_Add(callback)
    print("Mock method called with callback!\n", callback)
end

Events = {
    OnClientCommand = {
        Add = mockEvents.OnClientCommand_Add
    }
}
````
