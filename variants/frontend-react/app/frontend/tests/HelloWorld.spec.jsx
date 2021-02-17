import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import React from 'react';
import '@testing-library/jest-dom/extend-expect';
import HelloWorld from '../components/HelloWorld';

describe('HelloWorld', () => {
  it('renders personalized greeting', async () => {
    const { findByText } = render(
      <HelloWorld initialGreeting="Hello Ackama" />
    );

    await findByText(/hello ackama/iu);
    userEvent.type(
      screen.getByRole('textbox', {
        name: /change the greeting/iu
      }),
      'Hello from the other side'
    );
    expect(screen.getByText(/hello from the other side/iu)).toBeInTheDocument();
  });
});
