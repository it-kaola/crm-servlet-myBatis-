package com.bjpowernode.crm.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/*
* 该工具类实现的功能是将明文密码通过MD5算法生成密文
* 该过程是一个不可逆的过程，即通过算法，可将明文可以转密文，但是无法通过算法将密文转换为明文，除非穷举出所有密码的密文形式
* */

public class MD5Util {
	
	public static String getMD5(String password) {
		try {
			// 得到一个信息摘要器
			MessageDigest digest = MessageDigest.getInstance("md5");
			byte[] result = digest.digest(password.getBytes());
			StringBuffer buffer = new StringBuffer();
			// 把每一个byte 做一个与运算 0xff;
			for (byte b : result) {
				// 与运算
				int number = b & 0xff;// 加盐
				String str = Integer.toHexString(number);
				if (str.length() == 1) {
					buffer.append("0");
				}
				buffer.append(str);
			}

			// 标准的md5加密后的结果
			return buffer.toString();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return "";
		}
	}
	
}
