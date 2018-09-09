using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplashParticle : MonoBehaviour {

    [SerializeField]
    private ParticleSystem sprayParticle;
    [SerializeField]
    private Vector3 hidePosition = new Vector3(0,-10,0);
    [SerializeField]
    private string triggerName = "Water";

    private Vector3 _collisionPos;
    private bool _sprayActive = false;
    private Transform _defaultParent;
    private Vector3 _defaultScale = new Vector3(1, 1, 1);



    // Use this for initialization
    void Start () {
        _defaultParent = sprayParticle.transform.parent;
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == triggerName)
        {
            // adjust particle position
            sprayParticle.transform.parent = transform.parent;
            sprayParticle.transform.localScale = _defaultScale;
            _collisionPos = other.ClosestPoint(transform.localPosition);
            Debug.Log("wing: " + _collisionPos);
            sprayParticle.transform.localPosition = _collisionPos;
            Debug.Log("particle" + sprayParticle.transform.localPosition);
            // turn particle on
            if (!_sprayActive)
            {
                sprayParticle.Play();
                _sprayActive = true;

            }
        }
    }



    private void OnTriggerExit(Collider other)
    {
        if (other.tag == triggerName)
        {
            // hide particle
            sprayParticle.transform.parent = _defaultParent;
            sprayParticle.transform.localScale = _defaultScale;
            sprayParticle.transform.localPosition = hidePosition;
            sprayParticle.Stop();
            _sprayActive = false;
        }
    }
}
