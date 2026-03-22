using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TurretAimTarget : MonoBehaviour
{
    public Transform m_yaw;
    public Transform m_pitch;
    public Transform m_target;
    public float m_range = 10f;
    public float m_rotationSpeed = 40f;
    public float m_chaseSpeed = 5f;

    /*
    // Start is called before the first frame update
    void Start()
    {
        
    }
    */

    // Update is called once per frame
    void Update()
    {
        if (m_yaw != null)
        {
            float targetDistance = Vector3.Distance(m_yaw.position, m_target.position);
            if (targetDistance < m_range)
            {
                // Yaw
                Vector3 lookVectorYaw = m_target.position - m_yaw.position; // 수평 방향으로 바라볼 벡터
                lookVectorYaw.y = m_yaw.position.y; // 자기 자신의 높이로 세팅 (수평)
                lookVectorYaw = lookVectorYaw.normalized; // 정규화
                Quaternion targetLookYaw = Quaternion.LookRotation(lookVectorYaw, new Vector3(0f, 1f, 0f)); // 바라볼 목표 방향 쿼터니언
                Quaternion lerpLookYaw = Quaternion.Slerp(m_yaw.rotation, targetLookYaw, m_chaseSpeed * Time.deltaTime);
                m_yaw.rotation = lerpLookYaw;

                // Pitch
                float targetDistanceFromPitch = Vector3.Distance(m_pitch.position, m_target.position);
                Vector3 lookVectorPitch = m_pitch.forward * targetDistanceFromPitch; // Pitch 벡터는 현재 바라보는 forward 벡터에서 타겟 거리만큼 늘린 벡터여야 한다.
                lookVectorPitch.y = m_target.position.y - m_pitch.position.y; // 세로만 타겟의 높이로 보정. 미묘한 오차가 있지만 문제되지 않음.
                lookVectorPitch = lookVectorPitch.normalized;
                Quaternion targetLookPitch = Quaternion.LookRotation(lookVectorPitch, new Vector3(0f, 1f, 0f));
                Quaternion lerpLookPitch = Quaternion.Slerp(m_pitch.rotation, targetLookPitch, m_chaseSpeed * Time.deltaTime);
                m_pitch.rotation = lerpLookPitch;
            }
            else
            {
                m_yaw.Rotate(new Vector3(0f, 1f, 0f), m_rotationSpeed * Time.deltaTime);
            }
        }
    }
}
