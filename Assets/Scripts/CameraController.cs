using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour {
    [SerializeField]
    private MovementController birdMovement;
    private MouseController mouseController;
    private Transform birdTransform;
    private Camera cam;

    // movement
    private float currentSpeed = 0f;
    [SerializeField]
    private float moveSpeed = 10;
    [SerializeField]
    private float rotationSpeed = 5;
    [SerializeField]
    private float followDistance = 10;
    [SerializeField]
    private float followHeight = 10;
    [SerializeField]
    private float minHeight = 0;
    private Vector3 targetPosition;
    private Vector3 moveDir;

    // Use this for initialization
    void Start () {
        birdTransform = birdMovement.transform.GetChild(0);
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth;
    }
	
	// Update is called once per frame
	void Update () {
        // movement
        // update direction to target
        moveDir = (birdTransform.position - transform.position).normalized;
        targetPosition = birdTransform.position - (moveDir * followDistance); 
        // adjust speed if lagging behind
        moveSpeed = birdMovement.CurrentSpeed;
        currentSpeed = moveSpeed * Time.deltaTime;
        // update position
        targetPosition.y += followHeight * -Vector3.Cross(birdTransform.forward, new Vector3(0, birdTransform.rotation.x, 0)).z;
        // clamp min height
        if (targetPosition.y < 0)
        {
            targetPosition.y = 0;
        }
        transform.position = Vector3.Lerp(transform.position, targetPosition, currentSpeed);
        // rotate towards target
        //float angle = Mathf.Atan2(lookDir.x, lookDir.z) * Mathf.Rad2Deg;
        //transform.rotation = Quaternion.AngleAxis(angle, Vector3.up);
        transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(birdTransform.forward), rotationSpeed * Time.deltaTime);
        
    }


}
