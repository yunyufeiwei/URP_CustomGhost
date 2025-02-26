using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Trail_Manager : MonoBehaviour
{
    [Tooltip("需要生成残影的目标物体")]
    public GameObject trail_targetObject;
    
    [Tooltip("生成残影的数量")]
    public int trail_Count = 4;
    [Tooltip("生成残影的透明度")] 
    public float trail_Alpha = 1.0f;
    [Tooltip("生成残影的间隔时间，单位秒")] 
    public float trail_IntervalTime;
    [Tooltip("生成后残影消失的速度")] 
    public float trail_disapperSpeed;
    
    public bool needTexture = false;
    
    [ColorUsage(true,true)]
    public Color trailColor;

    //上一帧目标物体的位置
    private Vector3 targetObjectPosition;
    
    // Start is called before the first frame update
    void Start()
    {
        if (trail_Count > 0 && trail_targetObject != null)
        {
            for (int i = 0; i < this.trail_Count; i++)
            {
                //实例化残影的数量，当前实例化之后的物体会在场景在第一层级
                GameObject trail = new GameObject("trail" + i);
                //设置实例化残影模型的父类，这样可以更好的管理场景页面的层级关系，此时实例化的物体仅具有Transfoorm信息
                trail.transform.SetParent(this.transform);
                //对实例化的物体添加渲染需要的组件，此时组件里面的Mesh和Material是空的，需要使用代码添加
                trail.AddComponent<MeshFilter>();
                trail.AddComponent<MeshRenderer>();
                trail.GetComponent<MeshRenderer>().shadowCastingMode = ShadowCastingMode.Off;   //关闭残影省城阴影

                //声明一个材质，使用shader的路径名来实例化
                Material mat = new Material(Shader.Find("Art/Trail"));
                if (needTexture == false)
                {
                    mat.SetColor("_FresnelColor" , trailColor);
                }
                else
                {
                    mat.SetTexture("_MainTex" , this.trail_targetObject.GetComponent<SkinnedMeshRenderer>().material.mainTexture);
                    //使用脚本定义的颜色来重写shader里面定义的颜色
                    mat.SetColor("_FresnelColor" , trailColor);
                }
                trail.GetComponent<MeshRenderer>().material = mat;
                Trail_Control trail_control = trail.AddComponent<Trail_Control>();
                    
                trail.SetActive(false);
            }
            StartCoroutine(this.trailStart());
        }
    }

    IEnumerator trailStart()
    {
        while (true)
        {
            for (int i = 0; i < this.trail_Count; i++)
            {
                if (this.targetObjectPosition != this.trail_targetObject.transform.position)
                {
                    GameObject trail = this.transform.GetChild(i).gameObject;
                    trail.transform.position = this.trail_targetObject.transform.position;
                    trail.transform.rotation = this.trail_targetObject.transform.rotation;
                    if (trail.activeSelf == false)
                    {
                        trail.SetActive(true);
                    }
                    trail.GetComponent<Trail_Control>().init(trail_disapperSpeed , this.trail_targetObject.GetComponent<SkinnedMeshRenderer>(),trail_Alpha);
                }

                this.targetObjectPosition = this.trail_targetObject.transform.position;
                yield return new WaitForSeconds(this.trail_IntervalTime);
            }
        }
    }
}
