Shader "Custom/BRDF/BlinnPhong"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        [HDR]_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecPower("Specular Power", Float) = 10
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normal       : TEXCOORD1;
                float3 viewDir      : TEXCOORD2;
                float3 lightDir     : TEXCOORD3;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _SpecColor;
                half _SpecPower;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDir = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(IN.positionOS.xyz));
                OUT.lightDir = normalize(_MainLightPosition.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                IN.normal = normalize(IN.normal); // 이걸 안하면 버택스 사이 픽셀 노말의 길이가 1이 아닌 것들이 발생함.
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                float NdotL = saturate(dot(IN.normal, IN.lightDir));
                
                // BlinnPhong Specular
                float3 H = normalize(IN.lightDir + IN.viewDir);
                half spec = saturate(dot(H, IN.normal));
                spec = pow(spec, _SpecPower);
                half3 specColor = spec * _SpecColor.rgb;

                half3 ambient = SampleSH(IN.normal);
                half3 lighting = NdotL * _MainLightColor.rgb + ambient;
                color.rgb *= lighting;
                color.rgb += specColor;

                return color;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/DepthOnly" // URP 렌더 파이프라인 에셋에서 Depth Priming Mode를 켜면 DepthNormals 패스가 반드시 필요하다.
        UsePass "Universal Render Pipeline/Lit/DepthNormals" // URP 렌더 파이프라인 에셋에서 Depth Priming Mode를 켜면 DepthNormals 패스가 반드시 필요하다.
    }
}