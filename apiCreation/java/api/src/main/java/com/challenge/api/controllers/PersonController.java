package com.challenge.api.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;

import javax.validation.Valid;
import java.util.List;

import com.challenge.api.models.Person;
import com.challenge.api.repositories.PersonRepository;


@RestController
@RequestMapping("/people")
public class PersonController {
	@Autowired
	  private PersonRepository repository;

	  @RequestMapping(value = "/", method = RequestMethod.GET)
	  public List<Person> getAllPeople() {
	    return repository.findAll();
	  }

	  @RequestMapping(value = "/{lastName}", method = RequestMethod.GET)
	  public List<Person> getByLastName(@PathVariable("lastName") String lastName) {
	    return repository.findByLastName(lastName);
	  }
	  
	  @RequestMapping(value = "/", method = RequestMethod.POST)
	  public void insertPerson(@Valid
	  @RequestBody Person person) {
	    repository.save(person);
	  }
}