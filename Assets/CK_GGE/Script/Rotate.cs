using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public Transform m_rotateObject;
    public Vector3 m_rotateSpeed = Vector3.zero;

    // Update is called once per frame
    void Update()
    {
        if (m_rotateObject != null)
        {
            m_rotateObject.Rotate(m_rotateSpeed * Time.deltaTime);
        }
    }
}
