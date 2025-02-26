Shader "Art/Trail"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        
        [HDR]_FresnelColor("FresnelColor",Color) = (1,1,1,1)
        [PowerSlider(2)]_FresnelFactor("FresnelFactor",Range(0,20)) = 0.6
        _Alpha("Alpha",float) = 1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalWS  : TEXCOORD1;
                float3 viewWS    : TEXCOORD2;
            };

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float4 _FresnelColor;
                float  _FresnelFactor;
                float  _Alpha;
            CBUFFER_END

            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.viewWS = GetWorldSpaceViewDir(TransformObjectToWorld(v.positionOS.xyz));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 FinalColor;
                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);

                half3 worldNormalDir = normalize(i.normalWS);
                half3 worldViewDir = normalize(i.viewWS);

                half fresnelFactor = pow(1 - saturate(dot(worldNormalDir , worldViewDir)) , _FresnelFactor);

                FinalColor = half4(mainTex.rgb * _FresnelColor.rgb * fresnelFactor , fresnelFactor * _Alpha);                
                return FinalColor;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
    }
}
