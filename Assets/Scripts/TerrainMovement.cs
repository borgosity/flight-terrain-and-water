using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainMovement : MonoBehaviour {

    [SerializeField]
    private MouseController mouseMovement = null;


    //private int materialIndex = 0;  
    //private Renderer objRenderer = null;
    [SerializeField]
    private float _scrollXSpeed = 0f;
    [SerializeField]
    private float _scrollZSpeed = 0f;

    private float maxXScrollSpeed = 0.2f;
    private float maxZScrollSpeed = 0.75f;

    private void Start()
    {
        //objRenderer = GetComponent<Renderer>();
    }

    void LateUpdate()
    {
        //UpdateXScroll();
        //UpdateZScroll();
        //if (objRenderer.enabled)
        //{
        //    objRenderer.materials[materialIndex].SetFloat("_ScrollZSpeed", _scrollZSpeed);
        //    objRenderer.materials[materialIndex].SetFloat("_ScrollXSpeed", _scrollXSpeed);
        //}
    }

    private void UpdateXScroll()
    {
        float dirRaw = mouseMovement.CurrentRoll * 0.01f;
        float dirNormal = dirRaw < 0 ? Mathf.Floor(dirRaw) : Mathf.Ceil(dirRaw);

        if (Mathf.Abs(dirRaw) > 0.01f)
        {
            if (dirNormal > 0 && _scrollXSpeed < maxXScrollSpeed)
            {
                _scrollXSpeed += 0.001f * dirRaw;
            }

            if (dirNormal < 0 && _scrollXSpeed > -maxXScrollSpeed)
            {
                _scrollXSpeed += 0.001f * dirRaw;
            }
        }
        else
        {
            if (_scrollXSpeed > 0.001f)
            {
                _scrollXSpeed -= 0.001f;
            }
            else if (_scrollXSpeed < -0.001f)
            {
                _scrollXSpeed += 0.001f;
            }
            else
            {
                _scrollXSpeed = 0;
            }
        }
    }

    private void UpdateZScroll()
    {
        float dirRaw = mouseMovement.CurrentPitch * 0.01f;
        float dirNormal = dirRaw < 0 ? Mathf.Floor(dirRaw) : Mathf.Ceil(dirRaw);

        if (dirNormal < -0.01f)
        {
            if (_scrollZSpeed >= -maxZScrollSpeed && _scrollZSpeed < -0.002f)
            {
                _scrollZSpeed += 0.001f * Mathf.Abs(dirRaw);
                //Debug.Log("Slow SPEED: " + _scrollZSpeed);
            }
        }
        else
        {
            if (_scrollZSpeed > -0.001f && _scrollZSpeed < -maxZScrollSpeed)
            {
                _scrollZSpeed -= -0.001f;
            }
            else
            {
                _scrollZSpeed = -maxZScrollSpeed;
            }
            //Debug.Log("Faster SPEED: " + _scrollZSpeed);
        }


    }
}
