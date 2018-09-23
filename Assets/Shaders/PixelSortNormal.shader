Shader "Hidden/PixelSortNormal"
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
            #include "PixelSortFunctions.cginc"
            
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
            float     _uIteration;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 coord = i.vertex;
                bool checkPrevious = fmod(coord.x + _uIteration, 2.0) < 1.0;
                float2 pixel = float2(-1.0, 0.0) / _ScreenParams.xy;
                
                float2 uv = i.uv;
                fixed4 current = tex2D(_MainTex, uv);
                fixed4 reference = tex2D(_MainTex, checkPrevious ? uv - pixel : uv + pixel);
                
                if (checkPrevious){
                    if (compareColors(reference, current)){
                        return reference;
                    }
                } else {
                    if (compareColors(current, reference)){
                        return reference;
                    }
                }
                
                return current;
            }
            ENDCG
        }
    }
}
