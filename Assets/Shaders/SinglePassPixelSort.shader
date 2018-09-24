Shader "Hidden/SinglePassPixelSort"
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
            
            #define MAXSIZE 256
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 scrPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.scrPos = ComputeScreenPos(o.vertex);
                
                return o;
            }

            sampler2D _MainTex;

            const float4 v1 = float4(1.0, 1.0, 1.0, 1.0);
            const float fMax = float(256);
            const float4 fMax4 = float4(256,256,256,256);
            const float4x4 mMax= float4x4(float4(256,256,256,256), float4(256,256,256,256), float4(256,256,256,256), float4(256,256,256,256));
            
            float MM = 1.0;
            
            int accum[16];
            
            float4 tex(int x, float2 fragCoord) {
                return tex2D(_MainTex, float2(x, fragCoord.y / MM) / float(MAXSIZE)); 
            }
            
            void accumValue(float f){
                int i4 = int(floor(f * 15.0));
                
                [unroll]
                for(int i = 0; i<16; i++){
                    int accu = accum[i];
                    accu += i == i4? 1:0;
                    
                    accum[i] = accu;
                }
            }
            
            int2 find_Kth(int k){
                bool found = false;
                int value = 0;         
                int a = accum[0];
                
                for(int i = 0; i < 16; i++){
                    value = i;
                    if(k < accum[i]){
                        found=true;
                        break;
                    }
                    else{
                        k -= accum[i];
                    }
                   
                }
                
                return int2(value, k);
            }
            
            float4 findTexel(int value, int k, float2 fragCoord){
                float4 texel = float4(1.0, 0.0, 0.0, 1.0);
                
                for(int i = 0; i < MAXSIZE; i++){
                    float4 v = tex(i, fragCoord);
                    int i4 = int(floor(v.g * 15.0));
                    if(i4 == value) {
                        if(k==0){
                            texel = v;
                        }
                        k--;
                    }
                }
                return texel;
            
            }
            
            int getAccum(int n){
                int ret = 100;
                
                for(int i = 0; i<16; i++){
                    if(i==n){
                        ret = accum[i];
                    }
                }
                
                return ret;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                for(int z = 0; z < 16; z++){
                    accum[z] = 0;
                }
                
                float4 fragColor = float4(0,0,0,0);
                
                if(i.scrPos.x / MM > float(MAXSIZE * 2)){
                    discard;
                }
                if(i.scrPos.y / MM > float(MAXSIZE)) {
                    discard;
                }
                
                for(int w = 0; w < MAXSIZE; w++){
                    accumValue(tex(w, i.scrPos.xy).g);
                }
                int k = int(i.scrPos.x / MM);
                
                int2 order = find_Kth(k);
                
                fragColor += findTexel(order.r, order.g, i.scrPos.xy);
                
                if(i.scrPos.x / MM > float(MAXSIZE)){
                    return tex((uint(i.scrPos.x) - MAXSIZE) / uint(MM), i.scrPos.xy);
                }
                return fragColor;
            }
            ENDCG
        }
    }
}
