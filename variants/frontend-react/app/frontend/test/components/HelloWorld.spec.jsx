import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import React from 'react';
import HelloWorld from '../../components/HelloWorld';

describe('HelloWorld', () => {
  it('renders the initial greeting', async () => {
    const { container } = render(<HelloWorld initialGreeting="Hello Ackama" />);

    expect(container).toHaveTextContent(/Hello Ackama/iu);
  });

  describe('when the user types in a new greeting', () => {
    it('changes to render that one', async () => {
      const { container } = render(
        <HelloWorld initialGreeting="Hello Ackama" />
      );

      userEvent.type(
        screen.getByRole('textbox', {
          name: /change the greeting/iu
        }),
        'Hello from the other side'
      );

      expect(container).toHaveTextContent(/Hello from the other side/iu);
    });

    it('can be reset back to the initial greeting', async () => {
      const { container } = render(
        <HelloWorld initialGreeting="Hello Ackama" />
      );

      userEvent.type(
        screen.getByRole('textbox', {
          name: /change the greeting/iu
        }),
        'Hello from the other side'
      );

      expect(container).not.toHaveTextContent("Hello Ackama");

      userEvent.click(
        screen.getByText('Reset')
      )

      expect(container).toHaveTextContent("Hello Ackama");
    });
  });
});
