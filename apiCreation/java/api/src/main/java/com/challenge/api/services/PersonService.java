package com.challenge.api.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.challenge.api.models.Person;
import com.challenge.api.repositories.PersonRepository;


@Service
public class PersonService {
 
    private PersonRepository personRepository;
 
    public PersonService(PersonRepository personRepository) {
        this.personRepository = personRepository;
    }
 
    public Iterable<Person> list() {
        return personRepository.findAll();
    }
 
    public Iterable<Person> save(List<Person> people) {
        return personRepository.saveAll(people);
    }
    
    public void dropPeople() {
        personRepository.deleteAll();
    }
 
}