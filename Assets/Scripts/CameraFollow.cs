using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine;  
  
public class CameraFollow : MonoBehaviour  
{  
    public Transform target; // 跟随的目标  

    private Vector3 offset;

    private void Start()
    {
        if (target != null)
        {
            offset = transform.position - target.position;
        }
    }

    void LateUpdate()  
    {  
        if (target)
        {
            transform.position = target.position + offset;
        }  
    }  
}