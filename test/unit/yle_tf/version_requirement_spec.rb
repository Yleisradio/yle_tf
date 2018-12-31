# frozen_string_literal: true

require 'yle_tf/version_requirement'

describe YleTf::VersionRequirement do
  subject(:requirement) { described_class.new(requirements) }

  describe '#satisfied_by?' do
    context 'with no requirements' do
      let(:requirements) { nil }

      it 'satisfies all versions' do
        expect(requirement).to be_satisfied_by('0.11.11')
        expect(requirement).to be_satisfied_by('1.2.3-rc4')
      end
    end

    context 'with empty requirements' do
      let(:requirements) { [] }

      it 'satisfies all versions' do
        expect(requirement).to be_satisfied_by('0.11.11')
        expect(requirement).to be_satisfied_by('1.2.3-rc4')
      end
    end

    context 'with minimun requirement' do
      let(:requirements) { '>= 0.10' }

      it 'does not satisfy older versions' do
        expect(requirement).not_to be_satisfied_by('0.8.8')
        expect(requirement).not_to be_satisfied_by('0.10.0-beta2')
      end

      it 'satisfies the exact version' do
        expect(requirement).to be_satisfied_by('0.10')
        expect(requirement).to be_satisfied_by('0.10.0')
      end

      it 'satisfies newer versions' do
        expect(requirement).to be_satisfied_by('0.11.11')
        expect(requirement).to be_satisfied_by('1.2.3-rc4')
      end
    end

    context 'with minimun requirement' do
      let(:requirements) { '>= 0.10' }

      it 'does not satisfy older versions' do
        expect(requirement).not_to be_satisfied_by('0.8.8')
        expect(requirement).not_to be_satisfied_by('0.10.0-beta2')
      end

      it 'satisfies the exact version' do
        expect(requirement).to be_satisfied_by('0.10')
        expect(requirement).to be_satisfied_by('0.10.0')
      end

      it 'satisfies newer versions' do
        expect(requirement).to be_satisfied_by('0.11.11')
        expect(requirement).to be_satisfied_by('1.2.3-rc4')
      end
    end

    context 'with multiple requirements' do
      let(:requirements) { ['>= 0.9.10', '< 0.11'] }

      it 'does not satisfy older versions' do
        expect(requirement).not_to be_satisfied_by('0.8.8')
        expect(requirement).not_to be_satisfied_by('0.9.5')
      end

      it 'satisfies the correct version' do
        expect(requirement).to be_satisfied_by('0.9.10')
        expect(requirement).to be_satisfied_by('0.10.8')
      end

      it 'does not satisfy newer versions' do
        expect(requirement).not_to be_satisfied_by('0.11.11')
        expect(requirement).not_to be_satisfied_by('1.2.3-rc4')
      end
    end

    context 'with pessimistic version constraint' do
      let(:requirements) { ['~> 0.10.3'] }

      it 'does not satisfy older versions' do
        expect(requirement).not_to be_satisfied_by('0.8.8')
        expect(requirement).not_to be_satisfied_by('0.10.1')
      end

      it 'satisfies the correct version' do
        expect(requirement).to be_satisfied_by('0.10.3')
        expect(requirement).to be_satisfied_by('0.10.8')
      end

      it 'does not satisfy newer versions' do
        expect(requirement).not_to be_satisfied_by('0.11.11')
        expect(requirement).not_to be_satisfied_by('1.2.3-rc4')
      end
    end
  end
end
