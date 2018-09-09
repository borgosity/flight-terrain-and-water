Shader "Custom/TerrainTextureShader"{
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
			//_Height("Height", float) = 1.0
	[NoScaleOffset] _GrassTex("Grass Texture", 2D) = "white" {}
		_GrassMulti("Grass Multiplier", float) = 1.0
	[NoScaleOffset] _SandTex("Sand Texture", 2D) = "white" {}
		_SandMulti("Sand Multiplier", float) = 1.0
	[NoScaleOffset] _DirtTex("Dirt Texture", 2D) = "white" {}
		_DirtMulti("Dirt Multiplier", float) = 1.0
	[NoScaleOffset] _SnowTex("Snow Texture", 2D) = "white" {}
		_SnowMulti("Snow Multiplier", float) = 1.0
		_Tess("Tessellation", Range(1,32)) = 4
		_DispTex("Disp Texture", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 100.0)) = 0.3
		_NormalMap("Normalmap", 2D) = "bump" {}
		//_Color("Color", color) = (1,1,1,0)
		//_SpecColor("Spec color", color) = (0.5,0.5,0.5,0.5)
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 300

		CGPROGRAM
		#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
		#pragma target 4.6
#include "UnityCG.cginc"

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
				float2 uv_DispTex;
				float terrainHeight;
				float4 pos;
				half3 worldNorm;
			};
			// displace vertices
			sampler2D _DispTex;
			float _Displacement;

			Input disp(inout appdata v)
			{
				float2 d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).rb * _Displacement;
				// increase height using red
				v.vertex.xyz += v.normal * d.x;
				// decrease height using blue
				if (d.y > 0)
				{
					v.vertex.xyz -= v.normal * d.y;
				}
				
				Input so;
				float tH = v.vertex.y;
				so.terrainHeight = tH * _Displacement;
				so.uv_DispTex = v.texcoord;
				so.pos = UnityObjectToClipPos(v.vertex);
				so.worldNorm = UnityObjectToWorldNormal(v.normal);
				return so;
			}

			sampler2D _MainTex;
			sampler2D _NormalMap;
			fixed4 _Color;
			float _TexXOffset;
			float _TexYOffset;
			sampler2D _GrassTex, _SandTex, _DirtTex, _SnowTex;
			float _Height, _GrassMulti, _SandMulti, _DirtMulti, _SnowMulti;

			void surf(Input IN, inout SurfaceOutput o) 
			{
				//half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				float4 splat = tex2D(_MainTex, IN.uv_DispTex);
				fixed4 c = tex2D(_GrassTex, IN.uv_MainTex) * splat.g * _GrassMulti
					+ tex2D(_DirtTex, IN.uv_MainTex) * splat.r * _DirtMulti
					+ tex2D(_SandTex, IN.uv_MainTex) * splat.b * _SandMulti
					+ tex2D(_SnowTex, IN.uv_MainTex) * (1 - splat.r - splat.g - splat.b) * _SnowMulti;
				//}
				o.Albedo = c.rgb;
				o.Specular = 0.2;
				o.Gloss = 1.0;
				o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_DispTex));
			}
			ENDCG
		}
		FallBack "Diffuse"
}
