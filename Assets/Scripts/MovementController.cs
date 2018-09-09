using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementController : MonoBehaviour {
    [SerializeField]
    private MouseController mouseMovement = null;
    //[SerializeField]
    //private float rotationSpeed = 0.5f;
    [SerializeField]
    private float acceleration = 10;
    [SerializeField]
    private float speed = 10;
    [SerializeField]
    private float maxHeight = 100;
    private float minHeight = 0;

    private Quaternion _rigRotation;

    public float CurrentSpeed { get { return speed; } }

    // Use this for initialization
    void Start () {
        _rigRotation = new Quaternion();
    }
	
	// Update is called once per frame
	void Update () {
        UpdateHeight();
        UpdateRotation();
        UpdateMovement();
    }

    private void UpdateHeight()
    {
        float dirRaw = mouseMovement.CurrentPitch * 0.01f;
        float dirNormal = dirRaw < 0 ? Mathf.Floor(dirRaw) : Mathf.Ceil(dirRaw);

        if (Mathf.Abs(dirRaw) > 0.01f)
        {
            // go up
            if (dirNormal < 0 && transform.position.y < maxHeight)
            {
                transform.Translate((-Vector3.up * Time.deltaTime) * (dirRaw * acceleration), Space.World);
            }
            // go down
            if (dirNormal > 0 && transform.position.y > minHeight)
            {
                transform.Translate((-Vector3.up * Time.deltaTime) * (dirRaw * acceleration), Space.World);
            }
        }
    }

    private void UpdateRotation()
    {
        float dirRaw = mouseMovement.CurrentRoll * 0.01f;
        // get target rotation
        _rigRotation.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y + -dirRaw, transform.eulerAngles.z);
        transform.rotation = _rigRotation;
    }

    private void UpdateMovement()
    {
        float dirRaw = mouseMovement.CurrentPitch * 0.01f;

        transform.Translate((transform.forward * Time.deltaTime) * (speed + dirRaw), Space.World);
    }
}
