package atti;

import java.sql.*;
import java.util.*;

public class ClinicDao {
	/*
	 * 메소드 : ClinicDao#clinicUpdate() 
	 * 페이지 : clinicAction.jsp
	 * 시작 날짜 : 2024-05-26
	 * 담당자 : 김지훈 
	 */
	public static int clinicUpdate(int regiNo, int clinicNo, String clinicContent) throws Exception {
		int updateRow = 0;
		Connection conn = DBHelper.getConnection();
		
		String sql = "UPDATE clinic"
				+ " SET clinic_content = ?, update_date = NOW()"
				+ " WHERE regi_no = ?"
				+ " AND clinic_no = ?";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setString(1, clinicContent); // 진료 정보를 수정
		stmt.setInt(2, regiNo); // regi_no에 따른 진료 정보를 수정
		stmt.setInt(3, clinicNo); // clinicNo에 따른 진료 정보를 수정
		
		System.out.println(stmt  + " ====== ClinicDao#clinicUpdate() stmt");
		
		updateRow = stmt.executeUpdate();
		
		conn.close();
		return updateRow;
	}
	
	
	/*
	 * 메소드 : ClinicDao#clinicInsert() 
	 * 페이지 : clinicAction.jsp
	 * 시작 날짜 : 2024-05-26
	 * 담당자 : 김지훈 
	 */
	public static int clinicInsert(int regiNo, String clinicContent) throws Exception {
		int insertRow = 0;
		
		// 디버깅
		System.out.println("ClinicDatail#clinicInsert() regiNo: " + regiNo);
		
		Connection conn = DBHelper.getConnection();
		String sql = "INSERT INTO clinic(regi_no, clinic_content, clinic_cost, create_date, update_date)"
				+ " VALUES(?, ?, 5000, NOW(), NOW())";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, regiNo);
		stmt.setString(2, clinicContent);
		
		System.out.println(stmt  + " ====== ClinicDao#clinicInsert() stmt");
		
		insertRow = stmt.executeUpdate();
		
		conn.close();
		return insertRow;
		
	}
	
	/*
	 * 메소드 : ClinicDatail#clinicDetail() 
	 * 페이지 : clinicAction.jsp
	 * 시작 날짜 : 2024-05-26
	 * 담당자 : 김지훈 
	 */
	
	public static ArrayList<HashMap<String, Object>> clinicDetail(int regiNo) throws Exception {
		// 디버깅
		System.out.println("ClinicDatail#clinicDetailByClinic() regiNo: " + regiNo);
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		Connection conn = DBHelper.getConnection();
		String sql = "SELECT clinic_no clinicNo, regi_no regiNo,"
				+ " clinic_content clinicContent, create_date createDate,"
				+ " update_date updateDate"
				+ " FROM clinic"
				+ " WHERE regi_no = ?";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, regiNo);
		
		// 디버깅
		System.out.println("ClinicDatail#clinicDetailByClinic(): " + stmt);
		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()) {
			HashMap<String, Object> clinicList = new HashMap<String, Object>();
			clinicList.put("clinicNo", rs.getInt("clinicNo"));
			clinicList.put("regiNo", rs.getInt("regiNo"));
			clinicList.put("clinicContent", rs.getString("clinicContent"));
			clinicList.put("createDate", rs.getString("createDate"));
			clinicList.put("updateDate", rs.getString("updateDate"));
			list.add(clinicList);
		}
		conn.close();
		return list;
	}
	
	/*
	 * 메소드		: ClinicDao#clinicList()
	 * 페이지		: clinicList.jsp
	 * 시작 날짜	: 2024-05-23
	 * 담당자		: 한은혜
	*/	
	public static ArrayList<HashMap<String, Object>> clinicList(int empNo) throws Exception{
		
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
		// DB연결
		Connection conn = DBHelper.getConnection();
		/*
		 * 진료 리스트 쿼리 
		 * 조건 : 오늘 날짜의 진료 상태가 대기나 예약인 것, 사번이 로그인 사번과 같음 
		 * + 접수 정보(emp_no, regi_no, regi_content, regi_state, regi_date) 
		 * + 동물 정보(pet_no, pet_name, pet_kind, pet_birth) 
		 */
		String sql ="SELECT  r.emp_no empNo, r.regi_no regiNo, r.regi_content regiContent, r.regi_state regiState, r.regi_date regiDate,"
				+ " r.pet_no petNo, pet_name petName, pet_kind petKind, pet_birth petBirth,"
				+ " (SELECT COUNT(regi_no) FROM registration"
				+ " 	WHERE DATE(regi_date) = DATE(NOW())"
				+ "		AND emp_no = ?"
				+ "		AND (regi_state = '대기' OR regi_state ='예약')) totalRow"		// 총 행 수
				+ " FROM registration r"
				+ " LEFT JOIN pet p"
				+ " ON r.pet_no = p.pet_no "
				+ " WHERE DATE(r.regi_date) = DATE(NOW())"							// regi_date = 오늘 날짜 
				+ " AND r.emp_no = ?"
				+ " AND (r.regi_state = '대기' OR r.regi_state ='예약')"	
				+ " ORDER BY r.regi_date ASC";
		
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, empNo);
		stmt.setInt(2, empNo);
		
		System.out.println(stmt + " ====== ClinicDao#clinicList stmt");
		
		ResultSet rs = stmt.executeQuery();
		while(rs.next()){
			HashMap<String, Object> clinicList = new HashMap<String, Object>();
			clinicList.put("empNo", rs.getInt("empNo"));
			clinicList.put("regiNo", rs.getInt("regiNo"));
			clinicList.put("regiContent", rs.getString("regiContent"));	
			clinicList.put("regiState", rs.getString("regiState"));	
			clinicList.put("regiDate", rs.getString("regiDate"));	
			clinicList.put("petNo", rs.getInt("petNo"));
			clinicList.put("petName", rs.getString("petName"));	
			clinicList.put("petKind", rs.getString("petKind"));	
			clinicList.put("petBirth", rs.getString("petBirth"));
			clinicList.put("totalRow", rs.getInt("totalRow"));

			list.add(clinicList);
		}
		
		conn.close();
		return list;
	}
	
}
