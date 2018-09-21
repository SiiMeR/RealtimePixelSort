using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Pixelsort : MonoBehaviour
{

    public ComputeShader CSImagePixelSort;

    private int kernelID;

    private float iterations;
    // Start is called before the first frame update
    void Start()
    {
        kernelID = CSImagePixelSort.FindKernel("CSMain");
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        var sortingTexture = RenderTexture.GetTemporary(src.width, src.height, src.depth);
        sortingTexture.enableRandomWrite = true;
        
        sortingTexture.Create();

        CSImagePixelSort.SetFloat("uIteration", iterations++);
        CSImagePixelSort.SetTexture(kernelID, "Source", src);
        CSImagePixelSort.SetTexture(kernelID, "Result", sortingTexture);
        CSImagePixelSort.SetVector("Resolution", new Vector4(Screen.currentResolution.width, Screen.currentResolution.height));
        CSImagePixelSort.Dispatch(kernelID,  (sortingTexture.width + 7) / 8, (sortingTexture.height + 7) / 8, 1);
        
        Graphics.Blit(sortingTexture,dest);
        
        RenderTexture.ReleaseTemporary(sortingTexture);
    }
}
