#ifndef DIR_H
#define DIR_H

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <string.h>
#include <dirent.h>
#include <errno.h>

static inline int error (lua_State*, int);

static int ls (lua_State*);

static int ils_gc (lua_State*);
static int ils (lua_State*);
static int ils_gn (lua_State*);

static int has (lua_State*);

static const struct luaL_Reg dirlib [4];
int luaopen_dir (lua_State*);

#endif
