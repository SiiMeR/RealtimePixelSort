using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pixelsort : MonoBehaviour
{

    public ComputeShader CSImagePixelSort;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src,dest);
    }
}
