#include "dir.h"

static inline int error (lua_State* L, int n) {
    lua_pushnil(L);
    lua_pushstring(L, strerror(n));
    return 2; /* nil, strerror */
}

static int ls (lua_State* L) {
    const char* path = luaL_checkstring(L, 1);
    struct dirent* entry;
    DIR* dir;
    int i;

    dir = opendir(path);
    if (dir == NULL) {return error(L, errno);};

    i = 1;
    lua_newtable(L);
    while (1) {
        errno = 0;
        if ((entry = readdir(dir)) != NULL) {
            lua_pushstring(L, entry->d_name); /* value */
            lua_seti(L, -2, i++);
        } else {
            closedir(dir);
            if (errno != 0) {
                return error(L, errno);
            }; return 1;
        };
    }; return 0;
}

static int ils_gc (lua_State* L) {
    DIR* dir = *(DIR**) lua_touserdata(L, 1);
    if (dir) {closedir(dir);};
    return 0;
}

static int ils (lua_State* L) {
    DIR* dir = *(DIR**) lua_touserdata(L, lua_upvalueindex(1));
    struct dirent* entry;

    errno = 0;
    if ((entry = readdir(dir)) != NULL) {
        lua_pushstring(L, entry->d_name);
        return 1;
    } else if (errno != 0) {
        return error(L, errno);
    }; return 0;
}

static int ils_gn (lua_State* L) {
    DIR** dir = (DIR**) lua_newuserdatauv(L, sizeof(DIR*), 0);
    const char* path = luaL_checkstring(L, 1);

    luaL_getmetatable(L, "dir.ils");
    lua_setmetatable(L, -2);

    *dir = opendir(path);
    if (*dir == NULL) {return error(L, errno);};

    lua_pushcclosure(L, ils, 1);
    return 1;
}

static int has (lua_State* L) {
    const char* path = luaL_checkstring(L, 1);
    const char* file = luaL_checkstring(L, 2);
    struct dirent* entry;
    DIR* dir;

    dir = opendir(path);
    if (dir == NULL) {return error(L, errno);};

    while (1) {
        errno = 0;
        if ((entry = readdir(dir)) != NULL) {
            if (strcmp(entry->d_name, file) == 0) {
                closedir(dir);
                lua_pushboolean(L, 1); /* true */
                return 1;
            };
        } else {
            closedir(dir);
            if (errno != 0) {return error(L, errno);};
            lua_pushboolean(L, 0); /* false */
            return 1;
        };
    }; return 0;
}

static const struct luaL_Reg dirlib [4] = {
    {"ls", ls},
    {"ils", ils_gn},
    {"has", has},
    {NULL, NULL}
};

int luaopen_dir (lua_State* L) {
    luaL_newmetatable(L, "dir.ils");

    lua_pushcfunction(L, ils_gc);
    lua_setfield(L, -2, "__gc");

    luaL_setfuncs(L, dirlib, 0);
    lua_pushvalue(L, -1);

    lua_setglobal(L, "dir");
    return 1;
}
