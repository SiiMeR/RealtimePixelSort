Shader "Hidden/AlternativePixelSort"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            // glsl style mod
            #define mod(x, y) (x - y * floor(x / y))
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            int iFrame;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 texel = 1. / _ScreenParams.xy;
                
                float step_y = texel.y;
                float2 s = float2(0., -step_y);
                float2 n = float2(0., step_y);
                
                float4 im_n = tex2D(_MainTex, i.uv + n);
                float4 im = tex2D(_MainTex, i.uv);
                float4 im_s = tex2D(_MainTex, i.uv + s);
                
                float len_n = length(im_n);
                float len = length(im);
                float len_s = length(im_s);
                
                
                if(int(mod(float(iFrame) + i.vertex.y, 2.0)) == 0) {
                    if ((len_s > len)){
                        im = im_s;
                    }
                } else {
                    if ((len_n < len)){
                        im = im_n;
                    }
                }
                
                return im;
            }
            ENDCG
        }
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                return  tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
