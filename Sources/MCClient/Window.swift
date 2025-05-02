import GLFW3
import OpenGL

enum WindowError : Error
{
    case GLFWInitFailed(Int32)
    case WindowCreateFailed(Int32)
}

fileprivate var mousePositionCallbacks: [(Double, Double) -> Void] = []

class Window
{
    let window: OpaquePointer?

    var title: String {
        get {
            String(cString: glfwGetWindowTitle(window)!)
        }
        set {
            glfwSetWindowTitle(window, newValue.withCString { $0 })
        }
    }

    init(width: Int32, height: Int32, title: String) throws
    {
        glfwSetErrorCallback { error, description in
            print("GLFWError: \(error) \(String(cString: description!))")
        }

        glfwInitHint(GLFW_PLATFORM, GLFW_PLATFORM_X11)
        guard glfwInit() == GLFW_TRUE else {
            throw WindowError.GLFWInitFailed(glfwGetError(nil))
        }

        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 5)
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)

        window = glfwCreateWindow(width, height, title, nil, nil)
        guard window != nil else {
            throw WindowError.WindowCreateFailed(glfwGetError(nil))
        }

        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED)

        glfwSetWindowUserPointer(window, withUnsafePointer(to: self) { UnsafeMutableRawPointer(OpaquePointer($0)) })

        glfwSetCursorPosCallback(window) { glfwWindow, x, y in
            for callback in mousePositionCallbacks {
                callback(x, y)
            }
        }

        glfwMakeContextCurrent(window)

        glEnable(GL_DEPTH_TEST)

        glEnable(GL_DEBUG_OUTPUT)
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS)

        glDebugMessageCallback({ source, type, id, severity, length, message, userParam in
            let sourceString = switch source {
                case GL_DEBUG_SOURCE_API: "API"
                case GL_DEBUG_SOURCE_WINDOW_SYSTEM: "Window source"
                case GL_DEBUG_SOURCE_SHADER_COMPILER: "Shader compiler"
                case GL_DEBUG_SOURCE_THIRD_PARTY: "Third party"
                case GL_DEBUG_SOURCE_APPLICATION: "Application"
                case GL_DEBUG_SOURCE_OTHER: "Other"
                default: "???"
            }

            let typeString = switch (type) {
        		case GL_DEBUG_TYPE_ERROR: "Error"
        		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: "Deprecated behavior"
        		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: "Undefined behavior"
        		case GL_DEBUG_TYPE_PORTABILITY: "Portability"
        		case GL_DEBUG_TYPE_PERFORMANCE: "Performance"
        		case GL_DEBUG_TYPE_MARKER: "Marker"
        		case GL_DEBUG_TYPE_OTHER: "Other"
                default: "???"
    		}

        	let severityString = switch (severity) {
        		case GL_DEBUG_SEVERITY_NOTIFICATION: "Notification"
        		case GL_DEBUG_SEVERITY_LOW: "Low"
        		case GL_DEBUG_SEVERITY_MEDIUM: "Medium"
        		case GL_DEBUG_SEVERITY_HIGH: "High"
                default: "???"
    		}

            print("OpenGL \(severityString) Error from \(sourceString) - \(typeString) - \(String(cString: message))")

            if severity == GL_DEBUG_SEVERITY_HIGH {
                fatalError()
            }
        }, nil)
    }

    deinit
    {
        glfwDestroyWindow(window)
        glfwTerminate()
    }

    func shouldClose() -> Bool
    {
        return glfwWindowShouldClose(window) != 0
    }

    func update()
    {
        glfwSwapBuffers(window)
        glfwPollEvents()
    }

    func getKey(key: Int32) -> Bool
    {
        return glfwGetKey(window, key) == GLFW_PRESS
    }

    func addMousePositionCallback(callback: @escaping (Double, Double) -> Void)
    {
        mousePositionCallbacks.append(callback)
    }
}
