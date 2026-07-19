#include "render_module.h"
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <unordered_map>
#include <vector>
#include <iostream>

#define MAX_POINT_LIGHTS 8
#define MAX_SPOT_LIGHTS 8

struct Mesh {
    GLuint vao, vbo;
    int vertexCount;
};

static std::unordered_map<int, Mesh> meshRegistry;
static int nextMeshId = 1;

static GLFWwindow* g_window = nullptr;
static GLuint g_shaderProgram = 0;
static GLint g_modelLoc = -1, g_viewLoc = -1, g_projLoc = -1;

static void glfwErrorCallback(int error, const char* desc) {
    std::cerr << "GLFW Error [" << error << "]: " << desc << std::endl;
}

// --- shaders ---

static const char* vertexShaderSource = R"(
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 FragPos;
out vec3 Normal;

void main() {
    FragPos = vec3(model * vec4(aPos, 1.0));
    Normal = mat3(transpose(inverse(model))) * aNormal;
    gl_Position = projection * view * vec4(FragPos, 1.0);
}
)";

static const char* fragmentShaderSource = R"(
#version 330 core
in vec3 FragPos;
in vec3 Normal;
out vec4 FragColor;

#define MAX_POINT_LIGHTS 8
#define MAX_SPOT_LIGHTS 8

uniform vec4 objectColor;

uniform vec3 lightDir;
uniform vec3 lightColor;

uniform int numPointLights;
uniform vec3 pointLightPos[MAX_POINT_LIGHTS];
uniform vec3 pointLightColor[MAX_POINT_LIGHTS];
uniform float pointLightConstant[MAX_POINT_LIGHTS];
uniform float pointLightLinear[MAX_POINT_LIGHTS];
uniform float pointLightQuadratic[MAX_POINT_LIGHTS];

uniform int numSpotLights;
uniform vec3 spotLightPos[MAX_SPOT_LIGHTS];
uniform vec3 spotLightDir[MAX_SPOT_LIGHTS];
uniform vec3 spotLightColor[MAX_SPOT_LIGHTS];
uniform float spotLightInnerCutoff[MAX_SPOT_LIGHTS];
uniform float spotLightOuterCutoff[MAX_SPOT_LIGHTS];
uniform float spotLightConstant[MAX_SPOT_LIGHTS];
uniform float spotLightLinear[MAX_SPOT_LIGHTS];
uniform float spotLightQuadratic[MAX_SPOT_LIGHTS];

void main() {
    vec3 norm = normalize(Normal);
    vec3 ambient = 0.15 * lightColor;

    float dirDiff = max(dot(norm, -lightDir), 0.0);
    vec3 dirDiffuse = dirDiff * lightColor;

    vec3 pointDiffuse = vec3(0.0);
    for (int i = 0; i < numPointLights; i++) {
        vec3 toLight = pointLightPos[i] - FragPos;
        float dist = length(toLight);
        vec3 dir = toLight / max(dist, 0.0001); // avoid divide-by-zero
        float diff = max(dot(norm, dir), 0.0);
        float atten = 1.0 / (pointLightConstant[i] + pointLightLinear[i] * dist + pointLightQuadratic[i] * dist * dist);
        pointDiffuse += diff * pointLightColor[i] * atten;
    }

    vec3 spotDiffuse = vec3(0.0);
    for (int i = 0; i < numSpotLights; i++) {
        vec3 toSpot = spotLightPos[i] - FragPos;
        float spotDist = length(toSpot);
        vec3 spotDirToFrag = toSpot / max(spotDist, 0.0001);

        float theta = dot(spotDirToFrag, -spotLightDir[i]);
        float epsilon = spotLightInnerCutoff[i] - spotLightOuterCutoff[i];
        float spotIntensity = clamp((theta - spotLightOuterCutoff[i]) / max(epsilon, 0.0001), 0.0, 1.0);

        float spotDiff = max(dot(norm, spotDirToFrag), 0.0);
        float spotAttenuation = 1.0 / (spotLightConstant[i] + spotLightLinear[i] * spotDist + spotLightQuadratic[i] * spotDist * spotDist);
        spotDiffuse += spotDiff * spotLightColor[i] * spotAttenuation * spotIntensity;
    }

    vec3 result = (ambient + dirDiffuse + pointDiffuse + spotDiffuse) * objectColor.rgb;
    FragColor = vec4(result, objectColor.a);
}
)";

static GLint g_colorLoc = -1;
static GLint g_lightDirLoc = -1, g_lightColorLoc = -1;

// point light array uniform locations
static GLint g_numPointLightsLoc = -1;
static GLint g_pointPosLoc = -1, g_pointColorLoc = -1;
static GLint g_pointConstLoc = -1, g_pointLinearLoc = -1, g_pointQuadLoc = -1;

// spot light array uniform locations
static GLint g_numSpotLightsLoc = -1;
static GLint g_spotPosLoc = -1, g_spotDirLoc = -1, g_spotColorLoc = -1;
static GLint g_spotInnerLoc = -1, g_spotOuterLoc = -1;
static GLint g_spotConstLoc = -1, g_spotLinearLoc = -1, g_spotQuadLoc = -1;

static double g_scrollDeltaY = 0.0;

static void glfwScrollCallback(GLFWwindow* window, double xoffset, double yoffset) {
    g_scrollDeltaY += yoffset;
}

static GLuint compileShaderProgram() {
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, nullptr);
    glCompileShader(vertexShader);

    GLint success;
    GLchar infoLog[512];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertexShader, 512, nullptr, infoLog);
        std::cerr << "Vertex shader error: " << infoLog << std::endl;
    }

    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, nullptr);
    glCompileShader(fragmentShader);

    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragmentShader, 512, nullptr, infoLog);
        std::cerr << "Fragment shader error: " << infoLog << std::endl;
    }

    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);

    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(program, 512, nullptr, infoLog);
        std::cerr << "Program link error: " << infoLog << std::endl;
    }

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return program;
}

// --- mesh helpers ---

static Mesh createMeshInternal(const std::vector<GLfloat>& vertices) {
    Mesh mesh;
    mesh.vertexCount = (int)(vertices.size() / 6);

    glGenVertexArrays(1, &mesh.vao);
    glGenBuffers(1, &mesh.vbo);

    glBindVertexArray(mesh.vao);
    glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(GLfloat), vertices.data(), GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);

    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    return mesh;
}

static std::vector<GLfloat> readFloatArray(lua_State* L, int stackIndex) {
    std::vector<GLfloat> result;
    int len = (int)lua_rawlen(L, stackIndex);
    result.reserve(len);

    for (int i = 1; i <= len; i++) {
        lua_rawgeti(L, stackIndex, i);
        result.push_back((GLfloat)lua_tonumber(L, -1));
        lua_pop(L, 1);
    }

    return result;
}

// --- Lua bindings ---

static glm::vec3 g_cameraPos = glm::vec3(0, 0, 3);
static glm::vec3 g_cameraTarget = glm::vec3(0, 0, 0);

static int lua_setCamera(lua_State* L) {
    float px = (float)luaL_checknumber(L, 1);
    float py = (float)luaL_checknumber(L, 2);
    float pz = (float)luaL_checknumber(L, 3);
    float tx = (float)luaL_checknumber(L, 4);
    float ty = (float)luaL_checknumber(L, 5);
    float tz = (float)luaL_checknumber(L, 6);

    g_cameraPos = glm::vec3(px, py, pz);
    g_cameraTarget = glm::vec3(tx, ty, tz);

    return 0;
}

static int lua_init(lua_State* L) {
    int width = (int)luaL_optinteger(L, 1, 800);
    int height = (int)luaL_optinteger(L, 2, 600);
    const char* title = luaL_optstring(L, 3, "Engine Window");

    glfwSetErrorCallback(glfwErrorCallback);

    if (!glfwInit()) {
        luaL_error(L, "Failed to init GLFW");
        return 0;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    g_window = glfwCreateWindow(width, height, title, nullptr, nullptr);
    if (!g_window) {
        luaL_error(L, "Failed to create window");
        return 0;
    }

    glfwMakeContextCurrent(g_window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        luaL_error(L, "Failed to init GLAD");
        return 0;
    }

    glfwSetScrollCallback(g_window, glfwScrollCallback);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    g_shaderProgram = compileShaderProgram();
    g_modelLoc = glGetUniformLocation(g_shaderProgram, "model");
    g_viewLoc = glGetUniformLocation(g_shaderProgram, "view");
    g_projLoc = glGetUniformLocation(g_shaderProgram, "projection");
    g_colorLoc = glGetUniformLocation(g_shaderProgram, "objectColor");
    g_lightDirLoc = glGetUniformLocation(g_shaderProgram, "lightDir");
    g_lightColorLoc = glGetUniformLocation(g_shaderProgram, "lightColor");

    g_numPointLightsLoc = glGetUniformLocation(g_shaderProgram, "numPointLights");
    g_pointPosLoc = glGetUniformLocation(g_shaderProgram, "pointLightPos");
    g_pointColorLoc = glGetUniformLocation(g_shaderProgram, "pointLightColor");
    g_pointConstLoc = glGetUniformLocation(g_shaderProgram, "pointLightConstant");
    g_pointLinearLoc = glGetUniformLocation(g_shaderProgram, "pointLightLinear");
    g_pointQuadLoc = glGetUniformLocation(g_shaderProgram, "pointLightQuadratic");

    g_numSpotLightsLoc = glGetUniformLocation(g_shaderProgram, "numSpotLights");
    g_spotPosLoc = glGetUniformLocation(g_shaderProgram, "spotLightPos");
    g_spotDirLoc = glGetUniformLocation(g_shaderProgram, "spotLightDir");
    g_spotColorLoc = glGetUniformLocation(g_shaderProgram, "spotLightColor");
    g_spotInnerLoc = glGetUniformLocation(g_shaderProgram, "spotLightInnerCutoff");
    g_spotOuterLoc = glGetUniformLocation(g_shaderProgram, "spotLightOuterCutoff");
    g_spotConstLoc = glGetUniformLocation(g_shaderProgram, "spotLightConstant");
    g_spotLinearLoc = glGetUniformLocation(g_shaderProgram, "spotLightLinear");
    g_spotQuadLoc = glGetUniformLocation(g_shaderProgram, "spotLightQuadratic");

    return 0;
}

static int lua_getMouseScroll(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.getMouseScroll() called before render.init()");
        return 0;
    }
    lua_pushnumber(L, g_scrollDeltaY);
    g_scrollDeltaY = 0.0; // consume it — each frame only sees scroll since last poll
    return 1;
}

static glm::vec3 g_lightDir = glm::vec3(-0.5f, -1.0f, -0.3f);
static glm::vec3 g_lightColor = glm::vec3(1.0f, 1.0f, 1.0f);

static int lua_setLight(lua_State* L) {
    float dx = (float)luaL_checknumber(L, 1);
    float dy = (float)luaL_checknumber(L, 2);
    float dz = (float)luaL_checknumber(L, 3);
    float r = (float)luaL_checknumber(L, 4);
    float g = (float)luaL_checknumber(L, 5);
    float b = (float)luaL_checknumber(L, 6);

    g_lightDir = glm::normalize(glm::vec3(dx, dy, dz));
    g_lightColor = glm::vec3(r, g, b);

    return 0;
}

// --- point light array state ---
// Rebuilt each frame: Lua calls render.clearPointLights() then
// render.addPointLight(...) once per active PointLight, before beginFrame.
static std::vector<glm::vec3> g_pointPositions;
static std::vector<glm::vec3> g_pointColors;
static std::vector<float> g_pointConstants;
static std::vector<float> g_pointLinears;
static std::vector<float> g_pointQuadratics;

static int lua_clearPointLights(lua_State* L) {
    g_pointPositions.clear();
    g_pointColors.clear();
    g_pointConstants.clear();
    g_pointLinears.clear();
    g_pointQuadratics.clear();
    return 0;
}

static int lua_addPointLight(lua_State* L) {
    if ((int)g_pointPositions.size() >= MAX_POINT_LIGHTS) {
        return 0; // silently ignore extras beyond the cap
    }

    g_pointPositions.push_back(glm::vec3(
        (float)luaL_checknumber(L, 1),
        (float)luaL_checknumber(L, 2),
        (float)luaL_checknumber(L, 3)
    ));
    g_pointColors.push_back(glm::vec3(
        (float)luaL_checknumber(L, 4),
        (float)luaL_checknumber(L, 5),
        (float)luaL_checknumber(L, 6)
    ));
    g_pointConstants.push_back((float)luaL_optnumber(L, 7, 1.0));
    g_pointLinears.push_back((float)luaL_optnumber(L, 8, 0.09));
    g_pointQuadratics.push_back((float)luaL_optnumber(L, 9, 0.032));

    return 0;
}

// --- spot light array state, same pattern as point lights ---
static std::vector<glm::vec3> g_spotPositions;
static std::vector<glm::vec3> g_spotDirs;
static std::vector<glm::vec3> g_spotColors;
static std::vector<float> g_spotInners;
static std::vector<float> g_spotOuters;
static std::vector<float> g_spotConstants;
static std::vector<float> g_spotLinears;
static std::vector<float> g_spotQuadratics;

static int lua_clearSpotLights(lua_State* L) {
    g_spotPositions.clear();
    g_spotDirs.clear();
    g_spotColors.clear();
    g_spotInners.clear();
    g_spotOuters.clear();
    g_spotConstants.clear();
    g_spotLinears.clear();
    g_spotQuadratics.clear();
    return 0;
}

static int lua_addSpotLight(lua_State* L) {
    if ((int)g_spotPositions.size() >= MAX_SPOT_LIGHTS) {
        return 0; // silently ignore extras beyond the cap
    }

    g_spotPositions.push_back(glm::vec3(
        (float)luaL_checknumber(L, 1),
        (float)luaL_checknumber(L, 2),
        (float)luaL_checknumber(L, 3)
    ));
    g_spotDirs.push_back(glm::normalize(glm::vec3(
        (float)luaL_checknumber(L, 4),
        (float)luaL_checknumber(L, 5),
        (float)luaL_checknumber(L, 6)
    )));
    g_spotColors.push_back(glm::vec3(
        (float)luaL_checknumber(L, 7),
        (float)luaL_checknumber(L, 8),
        (float)luaL_checknumber(L, 9)
    ));

    float innerDeg = (float)luaL_optnumber(L, 10, 12.5);
    float outerDeg = (float)luaL_optnumber(L, 11, 17.5);
    g_spotInners.push_back(cosf(glm::radians(innerDeg)));
    g_spotOuters.push_back(cosf(glm::radians(outerDeg)));

    g_spotConstants.push_back((float)luaL_optnumber(L, 12, 1.0));
    g_spotLinears.push_back((float)luaL_optnumber(L, 13, 0.09));
    g_spotQuadratics.push_back((float)luaL_optnumber(L, 14, 0.032));

    return 0;
}

static int lua_createMesh(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    std::vector<GLfloat> vertices = readFloatArray(L, 1);
    Mesh mesh = createMeshInternal(vertices);

    int id = nextMeshId++;
    meshRegistry[id] = mesh;

    lua_pushinteger(L, id);
    return 1;
}

static int lua_drawMesh(lua_State* L) {
    int meshId = (int)luaL_checkinteger(L, 1);
    float x = (float)luaL_optnumber(L, 2, 0.0);
    float y = (float)luaL_optnumber(L, 3, 0.0);
    float z = (float)luaL_optnumber(L, 4, 0.0);
    float sx = (float)luaL_optnumber(L, 5, 1.0);
    float sy = (float)luaL_optnumber(L, 6, 1.0);
    float sz = (float)luaL_optnumber(L, 7, 1.0);
    float r = (float)luaL_optnumber(L, 8, 1.0);
    float g = (float)luaL_optnumber(L, 9, 0.5);
    float b = (float)luaL_optnumber(L, 10, 0.2);
    float rx = (float)luaL_optnumber(L, 11, 0.0);
    float ry = (float)luaL_optnumber(L, 12, 0.0);
    float rz = (float)luaL_optnumber(L, 13, 0.0);
    float a = (float)luaL_optnumber(L, 14, 1.0);

    auto it = meshRegistry.find(meshId);
    if (it == meshRegistry.end()) {
        luaL_error(L, "drawMesh: invalid mesh id %d", meshId);
        return 0;
    }

    glm::mat4 model = glm::translate(glm::mat4(1.0f), glm::vec3(x, y, z));
    model = glm::rotate(model, glm::radians(ry), glm::vec3(0, 1, 0)); // yaw
    model = glm::rotate(model, glm::radians(rx), glm::vec3(1, 0, 0)); // pitch
    model = glm::rotate(model, glm::radians(rz), glm::vec3(0, 0, 1)); // roll
    model = glm::scale(model, glm::vec3(sx, sy, sz));

    glUniformMatrix4fv(g_modelLoc, 1, GL_FALSE, glm::value_ptr(model));
    glUniform4f(g_colorLoc, r, g, b, a);

    Mesh& mesh = it->second;
    glBindVertexArray(mesh.vao);
    glDrawArrays(GL_TRIANGLES, 0, mesh.vertexCount);
    glBindVertexArray(0);

    return 0;
}

static int lua_beginFrame(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.beginFrame() called before render.init()");
        return 0;
    }

    glClearColor(0.1f, 0.1f, 0.15f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(g_shaderProgram);

    glm::mat4 view = glm::lookAt(g_cameraPos, g_cameraTarget, glm::vec3(0, 1, 0));
    glm::mat4 projection = glm::perspective(glm::radians(45.0f), 800.0f / 600.0f, 0.1f, 500.0f);

    glUniformMatrix4fv(g_viewLoc, 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(g_projLoc, 1, GL_FALSE, glm::value_ptr(projection));

    glUniform3f(g_lightDirLoc, g_lightDir.x, g_lightDir.y, g_lightDir.z);
    glUniform3f(g_lightColorLoc, g_lightColor.x, g_lightColor.y, g_lightColor.z);

    // --- point lights: upload whatever was accumulated via addPointLight
    // this frame, via the array uniform variants (note trailing 'v' and
    // the count parameter — these upload N vec3/float entries in one call,
    // not a single value like glUniform3f does) ---
    int numPoints = (int)g_pointPositions.size();
    glUniform1i(g_numPointLightsLoc, numPoints);
    if (numPoints > 0) {
        glUniform3fv(g_pointPosLoc, numPoints, glm::value_ptr(g_pointPositions[0]));
        glUniform3fv(g_pointColorLoc, numPoints, glm::value_ptr(g_pointColors[0]));
        glUniform1fv(g_pointConstLoc, numPoints, g_pointConstants.data());
        glUniform1fv(g_pointLinearLoc, numPoints, g_pointLinears.data());
        glUniform1fv(g_pointQuadLoc, numPoints, g_pointQuadratics.data());
    }

    // --- spot lights, same pattern ---
    int numSpots = (int)g_spotPositions.size();
    glUniform1i(g_numSpotLightsLoc, numSpots);
    if (numSpots > 0) {
        glUniform3fv(g_spotPosLoc, numSpots, glm::value_ptr(g_spotPositions[0]));
        glUniform3fv(g_spotDirLoc, numSpots, glm::value_ptr(g_spotDirs[0]));
        glUniform3fv(g_spotColorLoc, numSpots, glm::value_ptr(g_spotColors[0]));
        glUniform1fv(g_spotInnerLoc, numSpots, g_spotInners.data());
        glUniform1fv(g_spotOuterLoc, numSpots, g_spotOuters.data());
        glUniform1fv(g_spotConstLoc, numSpots, g_spotConstants.data());
        glUniform1fv(g_spotLinearLoc, numSpots, g_spotLinears.data());
        glUniform1fv(g_spotQuadLoc, numSpots, g_spotQuadratics.data());
    }

    return 0;
}

static int lua_endFrame(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.endFrame() called before render.init()");
        return 0;
    }
    glfwSwapBuffers(g_window);
    return 0;
}

static int lua_pollEvents(lua_State* L) {
    glfwPollEvents();
    return 0;
}

static int lua_shouldClose(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.shouldClose() called before render.init()");
        return 0;
    }
    bool close = glfwWindowShouldClose(g_window);
    lua_pushboolean(L, close);
    return 1;
}

static int lua_isKeyDown(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.isKeyDown() called before render.init()");
        return 0;
    }
    int key = (int)luaL_checkinteger(L, 1);
    int state = glfwGetKey(g_window, key);
    lua_pushboolean(L, state == GLFW_PRESS);
    return 1;
}

static int lua_getMousePos(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.getMousePos() called before render.init()");
        return 0;
    }
    double x, y;
    glfwGetCursorPos(g_window, &x, &y);
    lua_pushnumber(L, x);
    lua_pushnumber(L, y);
    return 2; // two return values... lua gets both x and y
}

static int lua_setCursorLocked(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.setCursorLocked() called before render.init()");
        return 0;
    }
    bool locked = lua_toboolean(L, 1);
    glfwSetInputMode(g_window, GLFW_CURSOR, locked ? GLFW_CURSOR_DISABLED : GLFW_CURSOR_NORMAL);
    return 0;
}

static int lua_isMouseButtonDown(lua_State* L) {
    if (!g_window) {
        luaL_error(L, "render.isMouseButtonDown() called before render.init()");
        return 0;
    }
    int button = (int)luaL_checkinteger(L, 1); // GLFW_MOUSE_BUTTON_LEFT/RIGHT/MIDDLE
    int state = glfwGetMouseButton(g_window, button);
    lua_pushboolean(L, state == GLFW_PRESS);
    return 1;
}

static const luaL_Reg renderFunctions[] = {
    {"init", lua_init},
    {"createMesh", lua_createMesh},
    {"beginFrame", lua_beginFrame},
    {"drawMesh", lua_drawMesh},
    {"endFrame", lua_endFrame},
    {"pollEvents", lua_pollEvents},
    {"shouldClose", lua_shouldClose},
    {"setCamera", lua_setCamera},
    {"isKeyDown", lua_isKeyDown},
    {"getMousePos", lua_getMousePos},
    {"setCursorLocked", lua_setCursorLocked},
    {"isMouseButtonDown", lua_isMouseButtonDown},
    {"setLight", lua_setLight},
    {"clearPointLights", lua_clearPointLights},
    {"addPointLight", lua_addPointLight},
    {"clearSpotLights", lua_clearSpotLights},
    {"addSpotLight", lua_addSpotLight},
    {"getMouseScroll", lua_getMouseScroll},
    {nullptr, nullptr}
};

extern "C" int luaopen_render(lua_State* L) {
    luaL_newlib(L, renderFunctions);
    return 1;
}