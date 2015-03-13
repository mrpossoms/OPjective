//
//  Shader.m
//  OPjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Shader.h"

@interface Shader()

@end

@implementation Shader

static GLint textureCounter = 0;
static Shader* currentShader = nil;
static NSMutableDictionary* compiledShaders;

#pragma mark - Private helper methods
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = [Shader sourceFromFile:file];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log for '%@':\n%s", file, log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)checkError{
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"Error: %x", err);
    assert(err == GL_NO_ERROR);
}

#pragma mark - Class methods

- (id) initShaderWithVertex:(NSString*) vertex
               withFragment:(NSString*) fragment
             withAttributes:(NSArray*) attributes{
    self = [super init];
    
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
  
    // allocate the compiled shaders dictionary if it hasn't been
    if(!compiledShaders){
        compiledShaders = [[NSMutableDictionary alloc] init];
    }
    
    // check to see if the this shader combination has been compiled and store yet
    // if so return the existing one instead
    Shader* existingShader = compiledShaders[[NSString stringWithFormat:@"%@%@", vertex, fragment]];
    if(existingShader){
        return existingShader;
    }
    
    [self checkError];
    
    // Create shader program.
    _programId = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertex ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return nil;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragment ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return nil;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_programId, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_programId, fragShader);
    
    int i = 0;
    for (NSString* attrib in attributes) {
        glBindAttribLocation(_programId, i++, [attrib UTF8String]);
    }
    
    [self checkError];
    
    // Link program.
    if (![self linkProgram:_programId]) {
        NSLog(@"Failed to link program: %d", _programId);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programId) {
            glDeleteProgram(_programId);
            _programId = 0;
        }
        
        return nil;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_programId, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_programId, fragShader);
        glDeleteShader(fragShader);
    }
    
    // Store the program into the dictionary
    compiledShaders[[NSString stringWithFormat:@"%@%@", vertex, fragment]] = self;
    
    return self;
}

- (void) dealloc
{
    if(currentShader == self)
        currentShader = nil;
    
    glDeleteProgram(_programId);
}

- (BOOL) bind
{
    if(self != currentShader){
        currentShader = self;
        glUseProgram(self.programId);
        textureCounter = 0;
        _drawn = NO;
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Uniform setters
- (void) usingTexture:(Texture *)texture withName:(const char*)name
{
    if(currentShader != self) [self bind];
    if(_drawn) return;
    
    // Activate and bind the texture
    glActiveTexture(GL_TEXTURE0 + textureCounter);
    glBindTexture(GL_TEXTURE_2D, texture.textureId);
            
    // find out where the texture lives in the shader program
    GLint loc = glGetUniformLocation(_programId, name);
    if(loc < 0){
        NSLog(@"Shader is missing uniform '%s'!", name);
        return;
    }
            
    // if the uniform was found, set it!
    glUniform1i(loc, textureCounter++);
}


- (void) usingFloat:(GLfloat*)vector ofLength:(int)length withName:(const char*)name
{
    // find out where the uniform lives in the shader program
    GLint loc = glGetUniformLocation(_programId, name);
    if(loc < 0){
        NSLog(@"Shader is missing uniform '%s'!", name);
        return;
    }
    
    switch (length) {
        case 1:
            glUniform1fv(loc, 1, vector);
            break;
        case 2:
            glUniform2fv(loc, 1, vector);
            break;
        case 3:
            glUniform3fv(loc, 1, vector);
            break;
        case 4:
            glUniform4fv(loc, 1, vector);
            break;
        default:
            break;
    }
}

- (void) usingArray:(GLvoid*)array ofLength:(int)length andType:(enum ShaderArrayType)type withName:(const char*)name
{
    // find out where the uniform lives in the shader program
    GLint loc = glGetUniformLocation(_programId, name);
    GLfloat* data = (GLfloat*)array;
    if(loc < 0){
        NSLog(@"usingArray: Shader is missing uniform '%s'!", name);
        return;
    }
    
    [self checkError];
    switch (type) {
        case floatArray:
            glUniform1fv(loc, length, data);
            break;
        case vec2Array:
            glUniform2fv(loc, length, data);
            break;
        case vec3Array:
            glUniform3fv(loc, length, data);
            break;
        case vec4Array:
            glUniform4fv(loc, length, data);
            break;
        case mat3Array:
            glUniformMatrix3fv(loc, length, GL_FALSE, data);
            break;
        default:
            NSLog(@"usingArray: Unrecognized array type!");
            break;
    }
    [self checkError];
}

- (void) usingMat4x4:(GLKMatrix4*)matrix withName:(const char*)name
{
    // find out where the uniform lives in the shader program
    GLint loc = glGetUniformLocation(_programId, name);
    if(loc < 0){
        NSLog(@"usingMat4x4: Shader is missing uniform '%s'!", name);
        return;
    }

    glUniformMatrix4fv(loc, 1, GL_FALSE, matrix->m);
}

+ (GLchar*)sourceFromFile:(NSString*)path
{
    return (GLchar *)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
}

@end

