Shader "Tecsup/S09/k"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
        _DetailBlend ("Detail Blend", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uvMain : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_DetailTex);
            SAMPLER(sampler_DetailTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _DetailTex_ST;
                float _DetailBlend;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                OUT.uvMain = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uvDetail = TRANSFORM_TEX(IN.uv, _DetailTex);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMain);
                half4 detail = SAMPLE_TEXTURE2D(_DetailTex, sampler_DetailTex, IN.uvDetail);

                float3 finalColor = albedo.rgb * lerp(float3(1.0, 1.0, 1.0), detail.rgb * 2.0, _DetailBlend);

                return half4(finalColor, albedo.a);
            }
            ENDHLSL
        }
    }
}