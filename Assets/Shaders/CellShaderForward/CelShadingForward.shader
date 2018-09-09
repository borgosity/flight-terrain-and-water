Shader "Custom/Cel_Shading_Forward" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_CutOff ("Alpha Cutoff", Range(0,1)) = 0.5
		_MainTex ("Main Texture", 2D) = "white" {}
	}
	SubShader {
		Tags {	"RenderType" = "Opaque"	}
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CelShadingForward alphatest:_CutOff addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		// lighting cel shading function
		half4 LightingCelShadingForward(SurfaceOutput surface, half3 lightDir, half atten) 
		{
			half NdotL = dot(surface.Normal, lightDir);
			// branching, instead of if else, could use
			NdotL = smoothstep(0, 0.025f, NdotL);
			half4 colour;
			colour.rgb = surface.Albedo * _LightColor0.rgb * (NdotL * atten * 2);
			colour.a = surface.Alpha;
			return colour;
		}

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput surfaceOut) {
			// Albedo comes from a texture tinted by color
			fixed4 colour = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			surfaceOut.Albedo = colour.rgb;
			surfaceOut.Alpha = colour.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
