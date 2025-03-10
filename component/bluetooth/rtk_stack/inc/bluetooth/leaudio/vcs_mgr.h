/*
 * Copyright (c) 2018, Realsil Semiconductor Corporation. All rights reserved.
 */

#ifndef _VCS_MGR_H_
#define _VCS_MGR_H_

#ifdef  __cplusplus
extern "C" {
#endif      /* __cplusplus */

#include "ble_audio_def.h"
#include "codec_def.h"
#include "vcs_def.h"

/**
 * \defgroup    LEA_GAF_VCP_Server Volume Control Server
 *
 * \brief   The server role for Volume Control Profile.
 */

/**
 * \defgroup    VCP_Server_Exported_Types Volume Control Server Exported Types
 *
 * \ingroup LEA_GAF_VCP_Server
 * @{
 */

/**
 * vcs_mgr.h
 *
 * \brief  Volume Control Service parameters.
 *
 * \ingroup VCP_Server_Exported_Types
 */
typedef struct
{
    uint8_t volume_setting;
    uint8_t mute;
    uint8_t change_counter; /**< This parameter takes effect only when @ref vcs_set_param is called for the first time.
                                 This parameter is used to initialize the Change_Counter field to an arbitrary value.*/
    uint8_t volume_flags;
    uint8_t step_size;
} T_VCS_PARAM;

/**
 * vcs_mgr.h
 *
 * \brief  VCS Volume State data.
 *
 * The message data for @ref LE_AUDIO_MSG_VCS_VOLUME_CP_IND.
 *
 * \ingroup VCP_Server_Exported_Types
 */
typedef struct
{
    uint16_t conn_handle;
    uint8_t volume_setting;
    uint8_t mute;
    T_VCS_CP_OP cp_op;
} T_VCS_VOLUME_CP_IND;
/**
 * End of VCP_Server_Exported_Types
 * @}
 */

/**
 * \defgroup    VCP_Server_Exported_Functions Volume Control Server Exported Functions
 *
 * \ingroup LEA_GAF_VCP_Server
 * @{
 */

/**
 * vcs_mgr.h
 *
 * \brief  Set Volume Control Service parameters.
 *
 * \param[in]  p_param      Pointer to VCS parameter: @ref T_VCS_PARAM.
 *
 * \return         The result of setting VCS parameters.
 * \retval true    Setting VCS parameters is successful.
 * \retval false   Setting VCS parameters failed.
 *
 * \ingroup VCP_Server_Exported_Functions
 */
bool vcs_set_param(T_VCS_PARAM *p_param);

/**
 * vcs_mgr.h
 *
 * \brief  Get Volume Control Service parameters.
 *
 * \param[in,out]  p_param      Pointer to VCS parameter: @ref T_VCS_PARAM.
 *
 * \return         The result of getting VCS parameters.
 * \retval true    Getting VCS parameters is successful.
 * \retval false   Getting VCS parameters failed.
 *
 * \ingroup VCP_Server_Exported_Functions
 */
bool vcs_get_param(T_VCS_PARAM *p_param);
/**
 * End of VCP_Server_Exported_Functions
 * @}
 */

#ifdef  __cplusplus
}
#endif      /*  __cplusplus */

#endif
