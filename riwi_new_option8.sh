	  8)
		root_use
		clear
		echo ""
		echo -e "${rw_cheng}━━━━━━ 添加 SSH 公钥 ━━━━━━${rw_lv}"
		echo ""

		# ── 选择目标用户 ──
		echo -e " ${rw_cheng}── 请选择目标用户 ──${rw_lv}"
		local _cur_usr=$(whoami)
		echo -e " ${rw_huang}0.   ${rw_lv}${_cur_usr}（当前用户）→ \$HOME/.ssh${rw_lv}"
		# 列出所有 uid >= 1000 的普通用户
		local _users_list=()
		while IFS=: read -r _u _p _uid _gid _gcos _home _shell; do
			[[ "$_uid" -ge 1000 ]] && [[ -d "$_home" ]] && _users_list+=("$_u")
		done </etc/passwd

		local _ui=1
		for _u in "${_users_list[@]}"; do
			local _h=$(getent passwd "$_u" | cut -d: -f6)
			echo -e " ${rw_huang}${_ui}.   ${rw_lv}${_u} → ${_h}/.ssh${rw_lv}"
			((_ui++))
		done
		echo -e "${rw_cheng}────────────────────────────────${rw_lv}"
		read -e -p " 请选择（默认0=当前用户）: " _usr_choice < /dev/tty
		_usr_choice="${_usr_choice:-0}"

		local _target_user _target_home
		if [[ "$_usr_choice" == "0" ]]; then
			_target_user="$_cur_usr"
			_target_home="$HOME"
		else
			_ui=1
			_target_user=""
			for _u in "${_users_list[@]}"; do
				if [[ "$_ui" == "$_usr_choice" ]]; then
					_target_user="$_u"
					break
				fi
				((_ui++))
			done
			if [[ -z "$_target_user" ]]; then
				red "无效选择"
				break_end
				continue
			fi
			_target_home=$(getent passwd "$_target_user" | cut -d: -f6)
			if [[ -z "$_target_home" ]] || [[ ! -d "$_target_home" ]]; then
				red "无法获取用户 ${_target_user} 的 home 目录"
				break_end
				continue
			fi
		fi

		_ssh_dir="${_target_home}/.ssh"
		_auth_file="${_ssh_dir}/authorized_keys"

		echo ""
		echo -e " ${rw_lv}目标用户: ${rw_huang}${_target_user}${rw_lv}  →  ${_ssh_dir}${rw_lv}"
		echo ""

		echo -e " 请选择操作:"
		echo -e " ${rw_huang}1.   ${rw_lv}粘贴已有公钥${rw_lv}"
		echo -e " ${rw_huang}2.   ${rw_lv}自动生成新密钥对${rw_lv}"
		echo -e " ${rw_huang}3.   ${rw_lv}查看已授权密钥${rw_lv}"
		echo -e "${rw_cheng}────────────────────────────────${rw_lv}"
		echo -e " ${rw_huang}0.   ${rw_lv}返回${rw_lv}"
		echo -e "${rw_cheng}────────────────────────────────${rw_lv}"
		read -e -p " 请选择: " _key_choice

		case $_key_choice in
		  1)
			echo ""
			read -e -p " 请粘贴 SSH 公钥（以 ssh-rsa/ssh-ed25519/ecdsa 开头）: " _pubkey < /dev/tty
			if [[ -n "$_pubkey" ]]; then
				mkdir -p "$_ssh_dir"
				echo "$_pubkey" >> "$_auth_file"
				chmod 700 "$_ssh_dir"
				chmod 600 "$_auth_file"
				chown -R "$_target_user":"$(id -gn "$_target_user" 2>/dev/null || echo "$_target_user")" "$_ssh_dir" 2>/dev/null
				green "公钥已添加到 ${_auth_file}"
			else
				red "公钥不能为空"
			fi
			;;
		  2)
			echo ""
			read -e -p " 请输入密钥名称（默认: id_ed25519）: " _key_name < /dev/tty
			_key_name="${_key_name:-id_ed25519}"
			_key_path="${_ssh_dir}/${_key_name}"

			if [[ -f "$_key_path" ]]; then
				yellow "密钥文件 ${_key_name} 已存在"
				read -e -p " 是否覆盖？(y/N): " _overwrite < /dev/tty
				[[ ! "$_overwrite" =~ ^[Yy]$ ]] && { yellow "已取消"; break_end; continue; }
			fi

			echo -e " 密钥类型:"
			echo -e " ${rw_huang}1.   ${rw_lv}ed25519（推荐，更安全更快）${rw_lv}"
			echo -e " ${rw_huang}2.   ${rw_lv}RSA 3072 位（兼容性更好）${rw_lv}"
			read -e -p " 请选择（默认1）: " _key_type_choice
			_key_type_choice="${_key_type_choice:-1}"

			local _key_type="ed25519"
			[[ "$_key_type_choice" == "2" ]] && _key_type="rsa"

			echo -e " ${rw_huang}正在生成 ${_key_type} 密钥对...${rw_lv}"
			mkdir -p "$_ssh_dir" && chmod 700 "$_ssh_dir"

			local _gen_ok=false
			if [[ "$_key_type" == "ed25519" ]]; then
				ssh-keygen -t ed25519 -f "$_key_path" -N "" -q 2>/dev/null && _gen_ok=true
			else
				ssh-keygen -t rsa -b 3072 -f "$_key_path" -N "" -q 2>/dev/null && _gen_ok=true
			fi

			if $_gen_ok; then
				cat "${_key_path}.pub" >> "$_auth_file"
				chmod 600 "$_auth_file"
				chown -R "$_target_user":"$(id -gn "$_target_user" 2>/dev/null || echo "$_target_user")" "$_ssh_dir" 2>/dev/null
				green "密钥对生成成功！"
				echo -e " ${rw_huang}私钥位置:${rw_lv} ${_key_path}"
				echo -e " ${rw_huang}公钥位置:${rw_lv} ${_key_path}.pub"
				echo -e " ${rw_hong}⚠ 请立即下载私钥保存到本地，否则无法 SSH 登录！${rw_lv}"
				echo -e "   ${rw_lv}下载方式: scp 或 SFTP 下载 ${_key_path}${rw_lv}"
			else
				red "密钥生成失败"
			fi
			;;
		  3)
			echo ""
			echo -e "${rw_cheng}━━━━━━ 已授权密钥 ━━━━━━${rw_lv}"
			if [[ -f "$_auth_file" ]] && [[ -s "$_auth_file" ]]; then
				cat "$_auth_file"
			else
				echo -e "暂无已授权的密钥"
			fi
			echo -e "${rw_cheng}────────────────────────────────${rw_lv}"
			;;
		  *)
			[[ "$_key_choice" != "0" ]] && red "无效的输入!"
			;;
		esac
		;;
