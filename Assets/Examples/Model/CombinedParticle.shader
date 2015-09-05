﻿Shader "Custom/CombinedParticle " {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		#pragma surface surf BlinnPhong vertex:vert
		#pragma target 3.0
		
		static const float3 HIDDEN_POSITION = float3(10000, 0, 0);
		
		#ifdef SHADER_API_D3D11
		#define COLLIDER_CAPACITY 10
		struct Collision {
			uint count;
			uint colliders[COLLIDER_CAPACITY];
		};
		int _Id;
		StructuredBuffer<float2> Positions;
		StructuredBuffer<float> Lifes;
		StructuredBuffer<Collision> Collisions;
		#endif

		sampler2D _MainTex;
		fixed4 _Color;
		half _Shininess;

		struct Input {
			float2 uv_MainTex;
			float4 color;
		};
		
		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			#ifdef SHADER_API_D3D11
			int id = round(v.texcoord1.x);
			float life = Lifes[id];
			Collision c = Collisions[id];
			o.color = lerp(float4(0, 0, 1, 1), float4(1, 0, 0, 1), c.count / 10.0);
			float3 worldPos = mul(_Object2World, float4(v.vertex.xyz, 1)).xyz;
			if (life > 0)
				worldPos.xy += Positions[id];
			else
				worldPos = HIDDEN_POSITION;
			v.vertex.xyz = mul(_World2Object, float4(worldPos, 1)).xyz;
			#endif
		}

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb * IN.color;
			o.Gloss = tex.a;
			o.Alpha = tex.a * _Color.a;
			o.Specular = _Shininess;
		}
		ENDCG
	} 
	FallBack Off
}
