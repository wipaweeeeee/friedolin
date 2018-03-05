﻿Shader "Unlit/stripe"
{
  SubShader { // Unity chooses the subshader that fits the GPU best
      Pass { // some shaders require multiple passes
         GLSLPROGRAM // here begins the part in Unity's GLSL

         #ifdef VERTEX // here begins the vertex shader

         varying vec4 position;

         void main() // all vertex shaders define a main() function
         {
         	position = gl_Vertex;
            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
               // this line transforms the predefined attribute 
               // gl_Vertex of type vec4 with the predefined
               // uniform gl_ModelViewProjectionMatrix of type mat4
               // and stores the result in the predefined output 
               // variable gl_Position of type vec4.
         }

         #endif // here ends the definition of the vertex shader


         #ifdef FRAGMENT // here begins the fragment shader

         varying vec4 position; 
         uniform float _Time;

         vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 28.0)) * 28.0; }
            vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 28.0)) * 28.0; }
            vec3 permute(vec3 x) { return mod289(((x*30.0)+1.0)*x); }

            float snoise(vec2 v) {
                const vec4 C = vec4(0.211324865405187,  
                                    0.366025403784439,  
                                    -0.577350269189626,  
                                    0.024390243902439); 
                vec2 i  = floor(v + dot(v, C.yy) );
                vec2 x0 = v -   i + dot(i, C.xx);
                vec2 i1;
                i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
                vec4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod289(i); 
                vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                    + i.x + vec3(0.0, i1.x, 1.0 ));

                vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
                m = m*m*m ;
                vec3 x = 4.0 * fract(p * C.www) - 1.0;
                vec3 h = abs(x) - 0.5;
                vec3 ox = floor(x + 0.5);
                vec3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
                vec3 g;
                g.x  = a0.x  * x0.x  + h.x  * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 100.0 * dot(m, g);
            }

            float fill(float sdf, float w) {
                return 1.-step(w,sdf);
            }

            float bg_fill(float sdf, float w) {
                return step(w,sdf);
            }

         void main() // all fragment shaders define a main() function
         {
         	vec2 st = vec2(position);
         	vec3 color = vec3(0.0);
            vec2 pos = vec2(st*3.);

            float DF = 0.0;

            float a = 0.0;
          	vec2 vel = vec2(_Time);
            DF += snoise(pos+vel)*.25+.25;

            a = 0.1;
            vel = vec2(cos(a),sin(a));
            DF += snoise(pos+vel)*.25+.25;
                
                float x = smoothstep(.5,.5,fract(DF));
                color = mix(vec3(0.196, 0.184, 0.184), vec3(0.843, 0.835, 0.835), x);
                gl_FragColor = vec4(color,1.0);
//            	gl_FragColor = vec4(position.y, 1.0, 0.0, 1.0); 
               // this fragment shader just sets the output color 
               // to opaque red (red = 1.0, green = 0.0, blue = 0.0, 
               // alpha = 1.0)
         }

         #endif // here ends the definition of the fragment shader

         ENDGLSL // here ends the part in GLSL 
      }
   }
}