using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseController : MonoBehaviour {

    [SerializeField, Tooltip("If left null scripts parent object used.")]
    private GameObject birdObject = null;
    [SerializeField, Tooltip("Mouse X input name.")]
    private string mouseXInput = "Mouse X";
    [SerializeField, Tooltip("Mouse Y input name.")]
    private string mouseYInput = "Mouse Y";
    [Header("Pitch")]
    [SerializeField, Tooltip("Max object pitch in degrees")]
    private float maxPitch = 85f;
    [SerializeField, Tooltip("Mouse pitch sensitivity"), Range(0, 1)]
    private float pitchSensitivity = 0.2f;
    [SerializeField, Tooltip("Current pitch in degrees")]
    private float currentPitch = 0;
    [Header("Roll")]
    [SerializeField, Tooltip("Max object roll in degrees")]
    private float maxRoll = 85f;
    [SerializeField, Tooltip("Mouse roll sensitivity"), Range(0, 1)]
    private float rollSensitivity = 0.25f;
    [SerializeField, Tooltip("Current roll in degrees")]
    private float currentRoll = 0;

    // private members
    private Quaternion _targetQuaternion;
    private float _targetRoll;
    private float _targetPitch;
    private bool _levelOut = false;

    // properties
    public float CurrentPitch { get{ return currentPitch; } }
    public float CurrentRoll { get { return currentRoll; } }

    private void Awake()
    {
        if (birdObject == null)
        {
            birdObject = gameObject;
        }

        _targetQuaternion = new Quaternion();
    }

    private void Start()
    {
		
	}

	private void Update()
    {
        _levelOut = true;
        
        // update roll
		if (Mathf.Abs(Input.GetAxis(mouseXInput)) > 0)
        {
            UpdateRoll(Input.GetAxis(mouseXInput));
            _levelOut = false;
        }
        // update pitch
        if (Mathf.Abs(Input.GetAxis(mouseYInput)) > 0)
        {
           UpdatePitch(Input.GetAxis(mouseYInput));
            _levelOut = false;
        }
        // level out
        if (_levelOut)
        {
           // LevelOut();
        }

    }

    private void UpdateRoll(float mouseX)
    {
        // get target rotation
        _targetQuaternion.SetFromToRotation(transform.up, transform.up + (Vector3.Cross(transform.forward, new Vector3(0, mouseX, 0)) * -rollSensitivity));
        _targetQuaternion = _targetQuaternion * transform.rotation;
        // get roll states
        _targetRoll = _targetQuaternion.eulerAngles.z > 180 ? _targetQuaternion.eulerAngles.z - 360 : _targetQuaternion.eulerAngles.z;
        // keep rolling if haven't reached max roll
        if (Mathf.Abs(_targetRoll) < maxRoll)
        {
            transform.rotation = _targetQuaternion;
        }
        // set current roll angle
        currentRoll = transform.eulerAngles.z > 180 ? transform.eulerAngles.z - 360 : transform.eulerAngles.z;

    }

    private void UpdatePitch(float mouseY)
    {
        // get target rotation
        _targetQuaternion.SetFromToRotation(transform.forward, transform.forward + new Vector3(0, (mouseY * pitchSensitivity), 0));
        _targetQuaternion = _targetQuaternion * transform.rotation;
        // get proposed pitch
        _targetPitch = _targetQuaternion.eulerAngles.x > 180 ? _targetQuaternion.eulerAngles.x - 360 : _targetQuaternion.eulerAngles.x;
        // update rotation if less than max pitch
        if (Mathf.Abs(_targetPitch) < maxPitch)
        {
            transform.rotation = _targetQuaternion;
        }
        // set current pitch angle
        currentPitch = transform.eulerAngles.x > 180 ? transform.eulerAngles.x - 360 : transform.eulerAngles.x;
    }

    private void LevelOut()
    {
        // get target rotation
        _targetQuaternion.SetFromToRotation(transform.forward, new Vector3(0, 1, 0));
        // get pitch states
        currentPitch = transform.eulerAngles.x > 180 ? transform.eulerAngles.x - 360 : transform.eulerAngles.x;
        _targetPitch = _targetQuaternion.eulerAngles.x > 180 ? _targetQuaternion.eulerAngles.x - 360 : _targetQuaternion.eulerAngles.x;
        transform.rotation = _targetQuaternion * transform.rotation;
    }
}
