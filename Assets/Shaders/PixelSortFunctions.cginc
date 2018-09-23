const float4 kRGBToYPrime = float4(0.299, 0.587, 0.114, 0.0);
const float4 kRGBToI      = float4(0.596, -0.275, -0.321, 0.0);
const float4 kRGBToQ      = float4(0.212, -0.523, 0.311, 0.0);

float4 getYIQC(float4 color) {
    float YPrime = dot(color, kRGBToYPrime);
    float I = dot(color, kRGBToI);
    float Q = dot(color, kRGBToQ);
    
    float chroma = sqrt(I * I + Q * Q);
    
    return float4(YPrime, I, Q, chroma);
}


bool compareColors(float4 a, float4 b){

    float4 aYIQC = getYIQC(a);
    float4 bYIQC = getYIQC(b);
    
    if (aYIQC.x > bYIQC.x) {
        return true;
    }
    
    if (aYIQC.x == bYIQC.x && aYIQC.w > bYIQC.w) {
        return true;
    } 
    
    return false;
}
