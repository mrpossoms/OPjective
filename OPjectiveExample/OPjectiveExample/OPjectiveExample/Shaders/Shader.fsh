//
//  Shader.fsh
//  OPjectiveExample
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
