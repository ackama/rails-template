import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import React from 'react';
import HelloWorld from '../../components/HelloWorld';

describe('HelloWorld', () => {
  it('renders the initial greeting', () => {
    const { container } = render(<HelloWorld initialGreeting="Hello Ackama" />);

    expect(container).toHaveTextContent(/Hello Ackama/iu);
  });

  describe('when the user types in a new greeting', () => {
    it('changes to render that one', async () => {
      const user = userEvent.setup();
      const { container } = render(
        <HelloWorld initialGreeting="Hello Ackama" />
      );

      await user.type(
        screen.getByRole('textbox', {
          name: /change the greeting/iu
        }),
        'Hello from the other side'
      );

      expect(container).toHaveTextContent(/Hello from the other side/iu);
    });

    it('can be reset back to the initial greeting', async () => {
      const user = userEvent.setup();

      const { container } = render(
        <HelloWorld initialGreeting="Hello Ackama" />
      );

      await user.type(
        screen.getByRole('textbox', {
          name: /change the greeting/iu
        }),
        'Hello from the other side'
      );

      expect(container).not.toHaveTextContent('Hello Ackama');

      await user.click(screen.getByText('Reset'));

      expect(container).toHaveTextContent('Hello Ackama');
    });
  });
});

