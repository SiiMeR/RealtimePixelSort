using UnityEngine;

[ExecuteInEditMode]
public class Pixelsort : MonoBehaviour
{

    public ComputeShader CSImagePixelSort;
    public Shader        FragmentShaderPixelSort;
    public GameObject    Plane;
    public Sprite        ImageToSort;

    private int _kernelId;
    private Material _pixelSortMat;
    private int _iterations;
    // Start is called before the first frame update
    private void Start()
    {
        Plane.GetComponent<Renderer>().sharedMaterial.mainTexture = ImageToSort.texture;
        
        _pixelSortMat = new Material(FragmentShaderPixelSort) { hideFlags = HideFlags.HideAndDontSave };
        
        _kernelId = CSImagePixelSort.FindKernel("CSMain");
    }

    private void SortTexture()
    {
        if (!FragmentShaderPixelSort || !CSImagePixelSort)
        {
            Debug.LogWarning("Required shaders not attached to script!");
            return;
        }

        var image = Plane.GetComponent<Renderer>().sharedMaterial.mainTexture;
        
        var sortingTexture1 = RenderTexture.GetTemporary(image.width, image.height);
        sortingTexture1.enableRandomWrite = true;
        
        sortingTexture1.Create(); 
        
        var sortingTexture2 = RenderTexture.GetTemporary(image.width, image.height);
        sortingTexture2.enableRandomWrite = true;
        
        sortingTexture2.Create();
        
        
        Graphics.Blit(image, sortingTexture1);
        
        for (var i = 0; i < 1000;i++)
        {   
            
            _pixelSortMat.SetFloat("_uIteration", i);
            Graphics.Blit(sortingTexture1, sortingTexture2, _pixelSortMat);
            Graphics.Blit(sortingTexture2, sortingTexture1, _pixelSortMat);
   
        }
        Plane.GetComponent<Renderer>().material.mainTexture = sortingTexture2;
        
        RenderTexture.ReleaseTemporary(sortingTexture1);
        RenderTexture.ReleaseTemporary(sortingTexture2);

    }

    /* private void Update()
     {
         if (!FragmentShaderPixelSort || !CSImagePixelSort)
         {
             Debug.LogWarning("Required shaders not attached to script!");
             return;
         }
 
         var image = Plane.GetComponent<Renderer>().material.mainTexture;
         
         var sortingTexture1 = RenderTexture.GetTemporary(image.width, image.height);
         sortingTexture1.enableRandomWrite = true;
         
         sortingTexture1.Create(); 
         
         var sortingTexture2 = RenderTexture.GetTemporary(image.width, image.height);
         sortingTexture2.enableRandomWrite = true;
         
         sortingTexture2.Create();
         _pixelSortMat.SetFloat("_uIteration", _iterations++);
 
 
         Graphics.Blit(image, sortingTexture1, _pixelSortMat);
 
         
         Plane.GetComponent<Renderer>().material.mainTexture = sortingTexture1;
         
         
      //   RenderTexture.ReleaseTemporary(sortingTexture1);
       //  RenderTexture.ReleaseTemporary(sortingTexture2);
     }*/

    private void Update()
    {

        if (Input.GetKeyDown(KeyCode.R))
        {
            Plane.GetComponent<Renderer>().sharedMaterial.mainTexture = ImageToSort.texture;
        }
        if (Input.GetKeyDown(KeyCode.F))
        {
            var tex = Plane.GetComponent<Renderer>().sharedMaterial.mainTexture;
            var result = new RenderTexture(tex.width, tex.height, 1, RenderTextureFormat.Default);
            
            Graphics.Blit(tex, result, _pixelSortMat);
            
            Plane.GetComponent<Renderer>().sharedMaterial.mainTexture = result;
        }
    }

//    private void OnRenderImage(RenderTexture src, RenderTexture dest)
//    {
//        _pixelSortMat.SetInt("iFrame", _iterations++);
//        Graphics.Blit(src, dest, _pixelSortMat);
//    }
}