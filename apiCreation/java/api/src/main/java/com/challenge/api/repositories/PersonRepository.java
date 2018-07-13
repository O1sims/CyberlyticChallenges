package com.challenge.api.repositories;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;

import com.challenge.api.models.Person;

public interface PersonRepository extends MongoRepository<Person, String> {
	
	List<Person> findByLastName(@Param("lastName") String lastName);

}