package com.challenge.api.models;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class Person {
	
	@Id 
	private ObjectId _id;
	
	private String firstName;
	private String lastName;
	private Integer age;

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public Integer getAge() {
		return age;
	}

	public void setAge(Integer age) {
		this.age = age;
	}

}