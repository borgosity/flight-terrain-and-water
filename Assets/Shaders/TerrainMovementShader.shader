Shader "Custom/TerrainMovement" {
	Properties{
		_Tess("Tessellation", Range(1,32)) = 4
		_MainTex("Base (RGB)", 2D) = "white" {}
	_DispTex("Disp Texture", 2D) = "gray" {}
	_NormalMap("Normalmap", 2D) = "bump" {}
	_Displacement("Displacement", Range(0, 100.0)) = 0.3

		_ScrollXSpeed("X scroll speed", Range(-10, 10)) = 0
		_ScrollZSpeed("Z scroll speed", Range(-10, 10)) = 0
		_Color("Color", color) = (1,1,1,0)
		_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 300

		CGPROGRAM
#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
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
	};

	sampler2D _MainTex;
	sampler2D _NormalMap;
	fixed4 _Color;

	void surf(Input IN, inout SurfaceOutput o) {
		fixed offsetX = _ScrollXSpeed * _Time;
		fixed offsetY = _ScrollZSpeed * _Time;
		fixed2 offsetUV = fixed2(offsetX, offsetY);
		// offset UVs
		fixed2 normalUV = IN.uv_NormalMap + offsetUV;
		fixed2 mainUV = IN.uv_MainTex + offsetUV;

		half4 c = tex2D(_MainTex, mainUV) * _Color;
		o.Albedo = c.rgb;

		float4 normalPixel = tex2D(_NormalMap, normalUV);
		float3 n = UnpackNormal(normalPixel);
		o.Normal = n.xyz;
		o.Specular = 0.2;
		o.Gloss = 1.0;
		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
}

