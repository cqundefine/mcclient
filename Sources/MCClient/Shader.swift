import Foundation
import OpenGL

enum ShaderError : Error
{
    case CompileError(stage: Shader.ShaderStage, error: String)
    case LinkError(String)
}

class Shader
{
    enum ShaderStage
    {
        case Vertex
        case Fragment
    }

    let program: GLuint

    init(vertexShaderSource: [UInt8], fragmentShaderSource: [UInt8]) throws
    {
        let vertexShader = try Shader.compileStage(source: vertexShaderSource, stage: .Vertex)
        let fragmentShader = try Shader.compileStage(source: fragmentShaderSource, stage: .Fragment)
        defer {
            glDeleteShader(vertexShader)
            glDeleteShader(fragmentShader)
        }

        program = glCreateProgram()

        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)

        var success: GLint = 0
        glGetProgramiv(program, GL_LINK_STATUS, &success)

        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetProgramInfoLog(program, 512, nil, &infoLog)
            throw ShaderError.LinkError(String(cString: infoLog))
        }
    }

    deinit
    {
        glDeleteProgram(program)
    }

    func use()
    {
        glUseProgram(program)
    }

    func setUniform(name: String, value: Int32)
    {
        let location = glGetUniformLocation(program, name)
        glUniform1i(location: location, v0: value)
    }

    func setUniform(name: String, value: Matrix4)
    {
        var val = value.data.raw
        let location = glGetUniformLocation(program, name)
        glUniformMatrix4fv(location: location, count: 1, transpose: false, value: withUnsafePointer(to: &val) { 
            $0.withMemoryRebound(to: Float.self, capacity: 1) { pointer in
                pointer
            }
        })
    }

    private static func compileStage(source: [UInt8], stage: ShaderStage) throws -> GLuint
    {
        let glStage = switch stage {
            case .Vertex: GL_VERTEX_SHADER
            case .Fragment: GL_FRAGMENT_SHADER
        }

        let shader = glCreateShader(glStage)

        let sourceString = String(decoding: Data(source), as: UTF8.self)
        sourceString.withCString { cstr in
            var s = [cstr]
            glShaderSource(shader: shader, count: 1, string: &s, length: nil)
        }
                
        glCompileShader(shader)

        var success: GLint = 0
        glGetShaderiv(shader, GL_COMPILE_STATUS, &success)

        guard success == GL_TRUE else {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shader, 512, nil, &infoLog)
            throw ShaderError.CompileError(stage: stage, error: String(cString: infoLog))
        }

        return shader
    }
}
