using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScrollTexture : MonoBehaviour
{
    private int materialIndex = 0;
    [SerializeField]
    private Vector2 uvAnimationRate = new Vector2(0f, -0.25f);
    private string textureName = "_MainTex";
    private Vector2 uvOffset = Vector2.zero;
    private Renderer objRenderer = null;

    private void Start()
    {
        objRenderer = GetComponent<Renderer>();
    }

    void LateUpdate()
    {
        uvOffset += (uvAnimationRate * Time.deltaTime);
        if (objRenderer.enabled)
        {
            objRenderer.materials[materialIndex].SetTextureOffset(textureName, uvOffset);
        }
    }
}

