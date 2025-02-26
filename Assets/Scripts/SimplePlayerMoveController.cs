using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class SimplePlayerMoveController : MonoBehaviour
{
    public Animator animator;
    public Rigidbody rig;
    public float speed = 0.0f;

    private Vector3 moveDirection = Vector3.zero;
    
    
    // Start is called before the first frame update
    void Start()
    {
        rig = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        float offset_vertical = Input.GetAxis("Vertical");
        float offset_Horizontal = Input.GetAxis("Horizontal");

        if (offset_vertical == 0.0f && offset_Horizontal == 0.0f)
        {
            this.animator.SetFloat("Speed", 0.0f);
        }
        else
        {
            this.animator.SetFloat("Speed", speed);
            
            this.moveDirection = new Vector3(offset_Horizontal, 0, offset_vertical) * speed;

            transform.position += this.moveDirection;
            transform.rotation  = Quaternion.LookRotation(moveDirection);
        }
        
        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            this.animator.SetBool("IsRun" , true);
            this.rig.AddForce(Vector3.up * 220);
        }
        if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            this.animator.SetBool("IsRun" , false);
            
        }
    }
}
