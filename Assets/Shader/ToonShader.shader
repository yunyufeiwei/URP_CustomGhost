Shader "Art/Toon" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
		[Toggle(OUTLINE_FRONT)] _OutlineFront("Enable Outline", Int) = 1
		_OutlineColor("OutlineColor",Color) = (0,0,0,1)
		_OutlineWidth("OutlineWidth",Float) = 0.2
	}
	SubShader 
	{
		Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry"}
		LOD 200
		
		Pass
		{
			Tags{"LightMode" = "UniversalForward" }
			Cull Back
			ZWrite On
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS		: NORMAL;
				float2 texcoord	: TEXCOORD;
			};
			
			struct Varyings
			{
				float4 positionHCS	: POSITION;
				float2 uv			: TEXCOORD0;
				float3 worldNormal	: TEXCOORD1;
			};

			TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
			CBUFFER_END

			Varyings vert(Attributes v)
			{
				Varyings o = (Varyings)0;

				o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
				o.worldNormal = TransformObjectToWorldNormal(v.normalOS);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			half4 frag(Varyings i):SV_TARGET
			{
				half4 FinalColor;
				Light light = GetMainLight();
				half3 lightDir = light.direction;
				half3 lightColor = light.color * light.distanceAttenuation;
				
				half4 mainTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);

				half3 worldNormalDir= i.worldNormal;
				
				half halfLambert = LightingLambert(lightColor,lightDir,worldNormalDir) * 0.5 + 0.5;

				FinalColor = mainTex * halfLambert;

				return FinalColor;
			
			}
			ENDHLSL
		}

		Pass
		{
			Name "OUTLINE"
			Tags{ "LightMode" = "SRPDefaultUnlit" }
			Cull Front

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature OUTLINE_FRONT
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 positionHCS : POSITION;
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _OutlineColor;
				float  _OutlineWidth;
			CBUFFER_END

			Varyings vert(Attributes v)
			{
				Varyings o = (Varyings)0;
				
				#if OUTLINE_FRONT
					o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
				
					float3 offsetDir = TransformObjectToWorldDir(v.positionOS.xyz);
					float2 offset = TransformWorldToHClipDir(offsetDir).xyz;
				
					o.positionHCS.xy += offset * o.positionHCS.w * _OutlineWidth;
				#else
						o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
				#endif
						return o;
			}

			half4 frag(Varyings i) :COLOR
			{
				half4 FinalColor;
				FinalColor = _OutlineColor;
				
				return FinalColor;
			}
			ENDHLSL
		}

		UsePass "Universal Render Pipeline/Lit/SHADOWCASTER"
	}
}
