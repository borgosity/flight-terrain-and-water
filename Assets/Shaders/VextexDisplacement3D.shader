Shader "Custom/VextexDisplacement3D" {
	Properties{
		_MainTex("Main Texture", 2D) = "white" {}
		_FancyMap("Detailed Texture", 2D) = "white" {}
		_HeightMap("HeightMap Texture", 2D) = "white" {}
		_Amount("Extrusion Amount", Range(0,100)) = 0.0
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		
		struct Input {
			float2 uv_MainTex;
			float2 uv2_FancyMap;
			float2 uv3_HeightMap;
		};

		sampler2D _MainTex;
		sampler2D _HeightMap;
		sampler2D _FancyMap;
		float4 _HeightMap_ST;
		//float4 _FancyMap_ST;
		float _Amount;

		void vert(inout appdata_full v) {
			float4 ivUV = float4(0,0,0,0);

			ivUV.xy = TRANSFORM_TEX(v.texcoord, _HeightMap);
			//ivUV.zw = TRANSFORM_TEX(v.texcoord, _FancyMap);
			float displacement = tex2Dlod(_HeightMap, float4(ivUV.xy, 0, 0)).r;
			displacement = displacement * _Amount;
			v.vertex.xyz += v.normal * displacement;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}
		ENDCG
	}
}
