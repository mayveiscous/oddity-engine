#include <irrKlang.h>
#include <lua.hpp>

#include <unordered_map>
#include <string>
#include <cstdint>

#ifdef _WIN32
#define AUDIO_API __declspec(dllexport)
#else
#define AUDIO_API
#endif

using namespace irrklang;

static ISoundEngine* g_engine = nullptr;

static std::unordered_map<int, ISound*> g_sounds;
static int g_nextSoundId = 1;

static int lua_init(lua_State* L) {
    if (g_engine) {
        lua_pushboolean(L, 1);
        return 1;
    }

    g_engine = createIrrKlangDevice();

    if (!g_engine) {
        lua_pushboolean(L, 0);
        return 1;
    }

    lua_pushboolean(L, 1);
    return 1;
}

static int lua_shutdown(lua_State* L) {
    for (auto& [id, sound] : g_sounds) {
        if (sound)
            sound->drop();
    }

    g_sounds.clear();

    if (g_engine) {
        g_engine->drop();
        g_engine = nullptr;
    }

    g_nextSoundId = 1;

    return 0;
}

static int lua_play(lua_State* L) {
    const char* path = luaL_checkstring(L, 1);
    bool looped = lua_toboolean(L, 2);
    bool startPaused = lua_toboolean(L, 3);

    if (!g_engine) {
        return luaL_error(L, "Audio engine is not initialized");
    }

    ISound* sound = g_engine->play2D(
        path,
        looped,
        startPaused,
        true
    );

    if (!sound) {
        lua_pushinteger(L, 0);
        return 1;
    }

    int id = g_nextSoundId++;

    g_sounds[id] = sound;

    lua_pushinteger(L, id);
    return 1;
}

static int lua_stop(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    ISound* sound = it->second;

    if (sound) {
        sound->stop();
        sound->drop();
    }

    g_sounds.erase(it);

    return 0;
}

static int lua_pause(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    if (it->second)
        it->second->setIsPaused(true);

    return 0;
}

static int lua_resume(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    if (it->second)
        it->second->setIsPaused(false);

    return 0;
}

static int lua_setVolume(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);
    float volume = (float)luaL_checknumber(L, 2);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    if (it->second)
        it->second->setVolume(volume);

    return 0;
}

static int lua_setPosition(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);

    float x = (float)luaL_checknumber(L, 2);
    float y = (float)luaL_checknumber(L, 3);
    float z = (float)luaL_checknumber(L, 4);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    if (it->second) {
        it->second->setPosition(
            vec3df(x, y, z)
        );
    }

    return 0;
}

static int lua_setLooped(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);
    bool looped = lua_toboolean(L, 2);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end())
        return 0;

    if (it->second)
        it->second->setIsLooped(looped);

    return 0;
}

static int lua_isFinished(lua_State* L) {
    int id = (int)luaL_checkinteger(L, 1);

    auto it = g_sounds.find(id);

    if (it == g_sounds.end()) {
        lua_pushboolean(L, 1);
        return 1;
    }

    if (!it->second) {
        lua_pushboolean(L, 1);
        return 1;
    }

    lua_pushboolean(
        L,
        it->second->isFinished()
    );

    return 1;
}

static const luaL_Reg audioFunctions[] = {
    {"init",         lua_init},
    {"shutdown",     lua_shutdown},
    {"play",         lua_play},
    {"stop",         lua_stop},
    {"pause",        lua_pause},
    {"resume",       lua_resume},
    {"setVolume",    lua_setVolume},
    {"setPosition",  lua_setPosition},
    {"setLooped",    lua_setLooped},
    {"isFinished",   lua_isFinished},

    {nullptr, nullptr}
};

extern "C" AUDIO_API int luaopen_oddity_audio(lua_State* L) {
    luaL_newlib(L, audioFunctions);
    return 1;
}