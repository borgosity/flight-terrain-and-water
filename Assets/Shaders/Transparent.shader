Shader "Custom/ClearWater"{
	Properties{
		_Tess("Tessellation", Range(1,32)) = 4
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Color("Color", color) = (1,1,1,0)
		_EdgeColor("Edge Color", color) = (1, 1, 1, 1)
		_DepthFactor("Depth Factor", float) = 1.0
		_NormalMap("Normalmap", 2D) = "bump" {}
		_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
		_DispTex("Disp Texture", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 100.0)) = 0.3
		_ScrollXSpeed("X scroll speed", Range(-10, 10)) = 0
		_ScrollZSpeed("Z scroll speed", Range(-10, 10)) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 300

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		//Pass
		//{
		//	CGPROGRAM

		//	#include "Tessellation.cginc"			
		//	#pragma vertex vert tessellate:tessFixed nolightmap
		//	#pragma fragment frag

		//	// tesselate
		//	float _Tess;

		//	float4 tessFixed()
		//	{
		//		return _Tess;
		//	}

		//	void vert()
		//	{

		//	}

		//	void frag()
		//	{

		//	}

		//	ENDCG
		//}

		Pass
		{
			CGPROGRAM
			// required to use ComputeScreenPos()
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			// Unity built-in - NOT required in Properties
			sampler2D _CameraDepthTexture;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float2 uv_MainTex : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 screenPos : TEXCOORD1;
			};

			// displace vertices
			sampler2D _DispTex;
			float _Displacement;
			fixed _ScrollXSpeed;
			fixed _ScrollZSpeed;

			vertexOutput vert(vertexInput input)
			{
				fixed offsetX = _ScrollXSpeed * _Time;
				fixed offsetY = _ScrollZSpeed * _Time;
				fixed2 offsetUV = fixed2(offsetX, offsetY);

				float2 d = tex2Dlod(_DispTex, float4(input.texcoord.xy + offsetUV, 0, 0)).rb * _Displacement;
				input.vertex.xyz += input.normal * d.x;
				if (d.y > 0)
				{
					input.vertex.xyz -= input.normal * d.y;
				}

				vertexOutput output;

				// convert obj-space position to camera clip space
				output.pos = UnityObjectToClipPos(input.vertex);

				// compute depth (screenPos is a float4)
				output.screenPos = ComputeScreenPos(output.pos);

				return output;
			}

			float _DepthFactor;
			fixed4 _Color;
			fixed4 _EdgeColor;
			sampler2D _MainTex;

			fixed4 frag(vertexOutput input) : COLOR
			{
				float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
				float depth = LinearEyeDepth(depthSample).r;

				// apply the DepthFactor to be able to tune at what depth values
				// the foam line actually starts
				float foamLine = 1 - saturate(_DepthFactor * (depth - input.screenPos.w));

				// multiply the edge color by the foam factor to get the edge,
				// then add that to the color of the water
				fixed4 c = _Color + foamLine * _EdgeColor;
				fixed3 baseColor = tex2D(_MainTex, input.uv_MainTex).rgb;
				c.rgb *= baseColor;


				return c;
			}

			ENDCG
		}

		//CGPROGRAM
		//#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp alpha:fade
		//#pragma target 4.6

		//struct appdata {
		//	float4 vertex : POSITION;
		//	float4 tangent : TANGENT;
		//	float3 normal : NORMAL;
		//	float2 texcoord : TEXCOORD0;
		//};

		//// displace vertices
		//sampler2D _DispTex;
		//float _Displacement;
		//fixed _ScrollXSpeed;
		//fixed _ScrollZSpeed;

		//void disp(inout appdata v)
		//{
		//	fixed offsetX = _ScrollXSpeed * _Time;
		//	fixed offsetY = _ScrollZSpeed * _Time;
		//	fixed2 offsetUV = fixed2(offsetX, offsetY);

		//	float2 d = tex2Dlod(_DispTex, float4(v.texcoord.xy + offsetUV,0,0)).rb * _Displacement;
		//	v.vertex.xyz += v.normal * d.x;
		//	if (d.y > 0)
		//	{
		//		v.vertex.xyz -= v.normal * d.y;
		//	}
		//}

		//// surface 
		//struct Input {
		//	float2 uv_MainTex;
		//	float2 uv_NormalMap;
		//	float3 worldNormal;
		//};

		//sampler2D _CameraDepthTexture;
		//sampler2D _MainTex;
		//sampler2D _NormalMap;
		//fixed4 _Color;
		//fixed _Transparency;


		//void surf(Input IN, inout SurfaceOutput o) {
		//	fixed offsetX = _ScrollXSpeed * _Time;
		//	fixed offsetY = _ScrollZSpeed * _Time;
		//	fixed2 offsetUV = fixed2(offsetX, offsetY);
		//	// offset UVs
		//	fixed2 normalUV = IN.uv_NormalMap + offsetUV;
		//	fixed2 mainUV = IN.uv_MainTex + offsetUV;

		//	half4 colour = tex2D(_MainTex, mainUV) * _Color;
		//	o.Albedo = colour.rgb;
		//	o.Specular = _SpecColor;
		//	o.Gloss = 1.0;
		//	o.Alpha = colour.a;
		//}
		//ENDCG
	}
		FallBack "Diffuse"
}
