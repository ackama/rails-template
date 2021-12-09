import React, { useCallback, useState } from 'react';
import { Form, TextInput } from '../utils';

type FormProps = React.ComponentProps<typeof Form>;
type FormOnSubmitHandler = Required<FormProps>['onSubmit'];
type FormOnResetHandler = Required<FormProps>['onReset'];

/**
 * Builds a full name out of the given parts of a name
 *
 * @param {string} firstName
 * @param {string} middleName
 * @param {string} lastName
 *
 * @return {string}
 */
const buildFullName = (
  firstName: string,
  middleName: string,
  lastName: string
) => {
  // trim to avoid a double space if middleName is empty
  const leftOfLastName = `${firstName} ${middleName}`.trim();

  return `${leftOfLastName} ${lastName}`;
};

const Index: React.VFC = () => {
  const [firstName, setFirstName] = useState('');
  const [middleName, setMiddleName] = useState('');
  const [lastName, setLastName] = useState('');

  const handleSubmit = useCallback<FormOnSubmitHandler>(
    event => {
      event.preventDefault();

      const fullName = buildFullName(firstName, middleName, lastName);

      alert(`Hello ${fullName}!`);
    },
    [firstName, middleName, lastName]
  );

  const handleReset = useCallback<FormOnResetHandler>(() => {
    setFirstName('');
    setMiddleName('');
    setLastName('');
  }, [setFirstName, setMiddleName, setLastName]);

  return (
    <Form onSubmit={handleSubmit} onReset={handleReset}>
      <TextInput
        id="first-name"
        label="First Name"
        value={firstName}
        required
        onChange={setFirstName}
      />
      <br />
      <TextInput
        id="middle-name"
        label="Middle Name"
        value={middleName}
        required={false}
        onChange={setMiddleName}
      />
      <br />
      <TextInput
        id="last-name"
        label="Last Name"
        value={lastName}
        required
        onChange={setLastName}
      />
    </Form>
  );
};

export default Index;
