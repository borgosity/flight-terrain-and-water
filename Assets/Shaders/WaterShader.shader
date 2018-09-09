Shader "Custom/WaterShader"{
	Properties{
		_Tess("Tessellation", Range(1,32)) = 4
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Color("Color", color) = (1,1,1,0)
		_Transparency("Water Transparency", Range(0,1)) = 0.5
		_NormalMap("Normalmap", 2D) = "bump" {}
		_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
		_DispTex("Disp Texture", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 100.0)) = 0.3
		_ScrollXSpeed("X scroll speed", Range(-10, 10)) = 0
		_ScrollZSpeed("Z scroll speed", Range(-10, 10)) = 0
		//_MinDist("Tessellation Min Distance", Range(1,32)) = 10
		//_MaxDist("Tessellation Max Distance", Range(1,32)) = 25
		//_EdgeLength("Edge length", Range(2,50)) = 15
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 300

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
	#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
	#pragma target 4.6
	#include "Tessellation.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};
		// tesselate
		float _Tess;
		//float _MinDist;
		//float _MaxDist;
		//float _EdgeLength;

		float4 tessFixed()
		{
			return _Tess;
		}
		//float4 tessDistance(appdata v0, appdata v1, appdata v2) {
		//	float minDist = 10.0;
		//	float maxDist = 25.0;
		//	return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
		//}
		//float4 tessEdge(appdata v0, appdata v1, appdata v2)
		//{
		//	return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		//}
		// displace vertices
		sampler2D _DispTex;
		float _Displacement;
		fixed _ScrollXSpeed;
		fixed _ScrollZSpeed;

		void disp(inout appdata v)
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
		}
		// surface 
		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalMap;
			float3 worldNormal;
		};

		sampler2D _MainTex;
		sampler2D _NormalMap;
		fixed4 _Color;
		fixed _Transparency;


		void surf(Input IN, inout SurfaceOutput o) {
			fixed offsetX = _ScrollXSpeed * _Time;
			fixed offsetY = _ScrollZSpeed * _Time;
			fixed2 offsetUV = fixed2(offsetX, offsetY);
			// offset UVs
			fixed2 normalUV = IN.uv_NormalMap + offsetUV;
			fixed2 mainUV = IN.uv_MainTex + offsetUV;

			half4 colour = tex2D(_MainTex, mainUV) * _Color;
			o.Albedo = colour.rgb;
			
			//float4 normalPixel = tex2D(_NormalMap, normalUV);
			//float3 n = UnpackNormal(normalPixel);
			//o.Normal = n.xyz;
			//o.Normal = IN.worldNormal;
			o.Specular = _SpecColor;
			o.Gloss = 1.0;
			o.Alpha = _Transparency;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
