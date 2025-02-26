using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Trail_Control : MonoBehaviour
{
    //声明一个外部传进来的骨骼模型的mesh
    public SkinnedMeshRenderer skinnedMeshRenderer;
    
    //残影消失的速度
    private float disappear_Speed;
    //残影的透明度
    private float alpha;
    //实例化残影的网格体变量
    private Mesh _bakeMeshResult;
    private Material _material;

    public void init(float disappear_speed, SkinnedMeshRenderer skinnedMeshRender, float alpha)
    {
        this.disappear_Speed = disappear_speed;
        this.skinnedMeshRenderer = skinnedMeshRender;
        this.alpha = alpha;

        if (this._bakeMeshResult == null)
        {
            this._bakeMeshResult = new Mesh();
        }
        
        this.skinnedMeshRenderer.BakeMesh(_bakeMeshResult);
        this.GetComponent<MeshFilter>().mesh = this._bakeMeshResult;
        this._material = this.GetComponent<MeshRenderer>().material;
    }

    void Update()
    {
        if (this._material != null)
        {
            this.alpha = Mathf.Lerp(this.alpha, 0, disappear_Speed * Time.deltaTime);
            this._material.SetFloat("alpha" , this.alpha);
            if (this.alpha < 0.0f)
            {
                this.gameObject.SetActive(false);
            }
        }
    }
}
