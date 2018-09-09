Shader "Custom/FoamyWaterShader"{
	Properties{
		_MainTex("Water Texture", 2D) = "white" {}
		_Color("Water Colour", color) = (1,1,1,0)
			_ColorMulti("ColorMultiplier", Range(0,1)) = 0.1
		_EdgeColor("Water Edge Colour", color) = (1, 1, 1, 1)
		_DepthFactor("Edge Depth Factor", Range(0,1)) = 1.0
		_SpecColor("Water Specular color", color) = (0.5,0.5,0.5,0.5)
		_Gloss("Water Gloss", Range(0,1)) = 1.0
		[Normal] _NormalMap("Normalmap", 2D) = "bump" {}
		_Tess("Wave Smoothness", Range(1,32)) = 4
		_DispTex("Wave Texture", 2D) = "gray" {}
		_Displacement("Wave Height", Range(0, 100.0)) = 0.3
		_ScrollXSpeed("Wave X scroll speed", Range(-10, 10)) = 0
		_ScrollZSpeed("Wave Z scroll speed", Range(-10, 10)) = 0
	}
	SubShader
	{
			Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 300

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
#include "UnityCG.cginc"

			#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap alpha:fade
			#pragma target 4.6

			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};
			// tesselate
			float _Tess;

			float4 tessFixed()
			{
				return _Tess;
			}

			// surface 
			struct Input {
				float2 uv_MainTex;
				float2 uv_NormalMap;
				float3 worldNormal;
				float4 screenPos;
				float3 worldPos;
			};
			// displace vertices
			sampler2D _DispTex;
			float _Displacement;
			fixed _ScrollXSpeed;
			fixed _ScrollZSpeed;

			Input disp(inout appdata v)
			{
				fixed offsetX = _ScrollXSpeed * _Time;
				fixed offsetY = _ScrollZSpeed * _Time;
				fixed2 offsetUV = fixed2(offsetX, offsetY);

				float2 d = tex2Dlod(_DispTex, float4(v.texcoord.xy + offsetUV,0,0)).rb * _Displacement;
				v.vertex.xyz += v.normal * d.x;
				if (d.y > 0)
				{
					v.vertex.xyz -= v.normal * d.y;
				}

				// convert obj-space position to camera clip space
				float4 pos = UnityObjectToClipPos(v.vertex);
				// compute depth (screenPos is a float4)
				Input so;
				so.screenPos = ComputeScreenPos(pos);
				so.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return so;
			}

			sampler2D _CameraDepthTexture;
			float _DepthFactor;
			fixed4 _EdgeColor;

			sampler2D _MainTex;
			sampler2D _NormalMap;
			fixed4 _Color;
			fixed _Transparency;
			float _Gloss;
			float _ColorMulti;


			void surf(Input IN, inout SurfaceOutput o) {
				fixed offsetX = _ScrollXSpeed * _Time;
				fixed offsetY = _ScrollZSpeed * _Time;
				fixed2 offsetUV = fixed2(offsetX, offsetY);
				// offset UVs
				fixed2 normalUV = IN.uv_NormalMap + offsetUV;
				fixed2 mainUV = IN.uv_MainTex + offsetUV;

				// Water edge foam
				float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, IN.screenPos);
				float depth = LinearEyeDepth(depthSample).r;
				// apply the DepthFactor to be able to tune at what depth values
				// the foam line actually starts
				float foamLine = 1 - saturate(_DepthFactor * (depth - IN.screenPos.w));

				// multiply the edge color by the foam factor to get the edge,
				// then add that to the color of the water
				fixed4 c = _Color + foamLine * _EdgeColor;
				fixed3 baseColor = tex2D(_MainTex, IN.uv_MainTex).rgb * (_ColorMulti * IN.worldPos.y + 1);
				c.rgb *= baseColor;

				o.Albedo = c.rgb;
				o.Specular = _SpecColor;
				o.Gloss = _Gloss;
				o.Alpha = c.a;
				o.Normal = WorldNormalVector(IN, o.Normal);//UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			}
			ENDCG
		}
	FallBack "Diffuse"
}
